require "test_helper"

class FolderTest < ActiveSupport::TestCase
  test "#accessible_for" do
    user_1 = create(:user)
    upload_1 = create(:upload, user: user_1)
    root_folder_1 = create(:folder, upload: upload_1)
    sub_folder_1 = create(:folder, parent: root_folder_1)

    user_2 = create(:user)
    upload_2 = create(:upload, user: user_2)
    root_folder_2 = create(:folder, upload: upload_2)
    sub_folder_2 = create(:folder, parent: root_folder_2)

    assert_equal [ root_folder_1, sub_folder_1 ], Folder.accessible_for(user_1).to_a
    assert_equal [ root_folder_2, sub_folder_2 ], Folder.accessible_for(user_2).to_a
  end
end
