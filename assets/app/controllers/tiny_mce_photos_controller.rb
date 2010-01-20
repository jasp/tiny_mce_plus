class TinyMcePhotosController < ApplicationController
  before_filter :login_required
  
  #because the TinyMCE image uploader can't provide the auth token
  skip_before_filter :verify_authenticity_token, :only => :create 

  def index
    @photos = TinyMcePhoto.paginate :page => params[:page], :order => "created_at DESC", :conditions => ['user_id = ?', current_user.id], :per_page => 10
    render :js => "$('#dynamic_images_list').html(\"#{escape_javascript(render(:partial => "photo_list", :locals => { :photos => @photos }))}\");"
  end

  def create
    @user = current_user

    @photo = TinyMcePhoto.new(params[:photo])
    @photo.user = @user

    if @photo.save
      GC.start
      responds_to_parent do
        render :js => "upload_image_callback('#{@photo.public_filename()}', '#{@photo.display_name}', '#{@photo.id}');"
      end                
    else
      responds_to_parent do
        render :js => "alert('Sorry, there was an error uploading the photo.')"
      end
    end
  end

end
