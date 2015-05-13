class ClassificationsController < ApplicationController
  respond_to :json

  # EARLY CODE TO FAKE SECONDARY SUBJECTS -STI
  # def show
  #   puts 'SHOW: ', params["subject_id"]
  #   subject_id  = params["subject_id"]
  #   respond_with  Classification.find_by( _id: params[:subject_id] )
  # end

  def create
    # puts '++++++++++++++++++++++++++++++++++'
    # puts 'ALL PARAMS: ', params
    annotations = params["annotations"]
    # subject_set_id  = BSON::ObjectId.from_string params["classifications"]["subject_set"]["id"]
    workflow_id = BSON::ObjectId.from_string params["classifications"]["workflow_id"]

    # location         = params["location"]
    annotations      = params["classifications"]["annotations"]
    started_at       = params["classifications"]["metadata"]["started_at"]
    finished_at      = params["classifications"]["metadata"]["finished_at"]
    user_agent       = request.headers["HTTP_USER_AGENT"]
    # TODO
    #user_id     = BSON::ObjectId.from_string params["user_id"]
    #use subject_id params
    subject_id = session.id #this should change, auth currently not working
    # puts '+++++++++++++++++++++++++'
    # puts 'ANNOTATIONS: ', annotations
    annotations.each do |annotation|
      subject_id = annotation["subject_id"]
      annotation
    end

    @result = Classification.create(
      workflow_id: workflow_id,
      subject_id: subject_id,
      location: location,
      annotations: annotations,
      started_at: started_at,
      finished_at: finished_at,
      user_agent: user_agent )
    respond_with @result
 
  end

  def terms
    workflow_id = params[:workflow_id]
    annotation_key = params[:annotation_key]
    q = params[:q]

    terms = Term.autocomplete workflow_id, annotation_key, q
    respond_with terms
  end
end
