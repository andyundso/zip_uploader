# ZIP Uploader

I recently uncovered one of my very first Rails projects, which included an option to download a ZIP file. However, the code seemed very inefficient to me and therefore I tried to optimize it in this project.

## Base functionality

You can create an account in ZIP uploader. This gives you access to its upload feature. It currently only accepts ZIP files for uploading. Afterward, the ZIP file gets extracted in a background job. Folders are saved with a hierarchy. Each folder can contain many files (model is called `Binary` since `File` is already taken in Ruby).

Once a file is uploaded and analyzed, you can browse its content and download the ZIP file again. This is the base for our comparison here.

## ZIP Builder v1

ZIP Builder v1 is the version I extracted from my original code repository. It's clearly an example taken from `rubyzip` themselves. What it does:

* It recreates the original structure of the ZIP file on the file system using a temporary directory.
* It compresses this temporary folder.
* It then uses `send_file` to send out data.

First of all, duplicating all files onto the file system is really inefficient. But it also takes ages until you get a response. Here is an example with a PopOS image which originally was 2.5 GB in size.

```
curl -v http://localhost:3000/api/v1/folders/13/download?api_token=riHuGJ1dnec1uzrjZXMhZpET -o output.zip
...
< x-runtime: 128.316631
< server-timing: start_processing.action_controller;dur=0.07, sql.active_record;dur=10.32, instantiation.active_record;dur=2.03, start_transaction.active_record;dur=0.02, transaction.active_record;dur=4.20, service_streaming_download.active_storage;dur=19565.24, send_file.action_controller;dur=0.42, process_action.action_controller;dur=128311.12
...
100 2522M  100 2522M    0     0  16.5M      0  0:02:32  0:02:32 --:--:--  108M 
```

So Rails told us that it took 2 minutes to process our request. This is quite a lot of time! The download itself then took roughly ~15seconds.

## ZIP Builder v2

So my first thought was to optimize that the files are no longer duplicated onto the filesystem, but rather using `rubyzip`'s `OutputStream` to read the chunks from ActiveStorage directly into a ZIP.

Let's see if this has also an effect on our performance.

```
curl -v http://localhost:3000/api/v2/folders/13/download?api_token=riHuGJ1dnec1uzrjZXMhZpET -o output.zip
...
< x-runtime: 106.023002
< server-timing: start_processing.action_controller;dur=0.06, sql.active_record;dur=12.57, instantiation.active_record;dur=0.95, start_transaction.active_record;dur=0.00, transaction.active_record;dur=3.65, service_streaming_download.active_storage;dur=105717.16, send_file.action_controller;dur=0.58, process_action.action_controller;dur=106014.52
...
100 2522M  100 2522M    0     0  19.8M      0  0:02:07  0:02:07 --:--:--  123M
```

not bad, an improvement of 30 seconds overall.

## v4

We solved the issue with the storage requirement and also gained a bit of performance.

However, the performance is still not good: When downloading our 2.5GB example file, the user waits around 2 minutes to get an initial response from our server. Consider that users generally loose patience after 1 seconds of waiting, 2 minutes is definitely too long. Let's see if we can optimize this.

To make this happen, we need two pieces:

You can include a module called `ActionController::Live` ([docs](https://api.rubyonrails.org/classes/ActionController/Live.html)). What it allows you is to send content as you generate it. However, it has three important constraints:

> You cannot write headers after the response has been committed

Essentially, you really need to be sure that you can send the entire content you plan to send. For example, if we start sending content, but note that some of our content is missing, we cannot suddenly change our answer to a `404` response code.

> You must call close on your stream when you’re finished, otherwise the socket may be left open forever.

This, in itself, does not sound too strange but plays into the third caveat.

> The final caveat is that your actions are executed in a separate thread than the main thread.

As long as the stream is not closed, the thread likely also remains open.

The second piece to our optimized sending mechanism is `zip_kit`. `zip_kit` can compress stuff "on-the-fly" into a stream. So we can read some bytes from files, `zip_kit` compresses it and writes it to an output stream. This output stream can be our stream for `ActionController::Live`, which enables a quick first response. 

Let's see how this performs:

```
curl -v http://localhost:3000/api/v4/folders/13/download?api_token=riHuGJ1dnec1uzrjZXMhZpET -o output.zip
...
< x-runtime: 0.927556
< server-timing: sql.active_record;dur=68.79, start_processing.action_controller;dur=0.08, instantiation.active_record;dur=47.34, start_transaction.active_record;dur=0.84, transaction.active_record;dur=32.76
...
100 2522M    0 2522M    0     0  26.3M      0 --:--:--  0:01:35 --:--:-- 27.3M
```

The Rails server gives us an answer in under 1 seconds, the entire download finishes in little over 90 seconds. So not only did we reach the magic figure of "under 1 second response time", but the download is also 20 seconds faster!

## Memory leak with Rake v2

If you do not read the docs about `ActionController::Live` carefully, you might miss this hint about buffering:

> Note that Rails includes Rack::ETag by default, which will buffer your response. As a result, streaming responses may not work properly with Rack 2.2.x, and you may need to implement workarounds in your application. You can either set the ETag or Last-Modified response headers or remove Rack::ETag from the middleware stack to address this issue.

My Rails 8 application ships with Rack v3 by default, but you can force it to downgrade to v2 by adding this line to the `Gemfile`.

```diff
--- a/Gemfile
+++ b/Gemfile
@@ -51,6 +51,8 @@ gem "memory_profiler"
 # Efficient ZIP streaming
 gem "zip_kit"
 
+gem "rack", "< 3.0"
+
 group :development, :test do
   # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
   gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
```

Grab a software to monitor your memory usage and try to download a large file out of the application. You can see how the memory ramps up, since Rails buffers your entire file in memory.

So be sure to apply the following code:

```ruby
response.headers["Last-Modified"] = Time.now.httpdate
```

## Does this make sense?

I would recommend not using any ZIP compression if you expose large files only (or single files which do not make sense to download as a collection). Combined with streaming download you also do not run into memory issues when using ActiveStorage. For example, the ISO download is much faster without compression.

```
curl -v http://localhost:3000/api/v1/binaries/15/download?api_token=riHuGJ1dnec1uzrjZXMhZpET -o pop_os.iso
...
< x-runtime: 0.243310
< server-timing: start_processing.action_controller;dur=0.25, sql.active_record;dur=26.26, instantiation.active_record;dur=19.25, start_transaction.active_record;dur=0.00, transaction.active_record;dur=16.91
...
100 2534M    0 2534M    0     0   270M      0 --:--:--  0:00:09 --:--:--  248M
```
