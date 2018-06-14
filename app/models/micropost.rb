class Micropost < ApplicationRecord
  belongs_to :user
  scope :by_user, ->(user_id){where user_id: user_id}
  mount_uploader :picture, PictureUploader
  validates :user_id, presence: true
  validates :content, presence: true,
    length: {maximum: Settings.content.maximun}
  validate  :picture_size

  def picture_size
    return unless picture.size > Settings.weigth_image.megabytes
    errors.add :picture, t("shoule_be_less")
  end
end
