require 'active_support'
require 'active_support/core_ext'
require 'erb'
require_relative './session'
require 'active_support/inflector'

class ControllerBase
  attr_reader :req, :res, :params

  # Setup the controller
  def initialize(req, res)
    @req = req
    @res = res
  end

  # Helper method to alias @already_built_response
  def already_built_response?
    @already_built_response ||= false
  end

  # Set the response status code and header
  def redirect_to(url)
    res.status = 302
    res.header['location'] = url
    session.store_session(res)
    if @already_built_response 
      raise "Already rendered!"
    else
      @already_built_response = true
    end
  end

  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, content_type = "text/html")
    res["Content-Type"] = content_type
    res.write(content)
    res.finish
    session.store_session(res)
    if @already_built_response 
      raise "Already rendered!"
    else
      @already_built_response = true
    end
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    dir_path = File.dirname(__FILE__)
    dir_path = File.expand_path("..", dir_path)
    controller_name = self.class.to_s.underscore
    template_path = File.join(dir_path,"views",controller_name,"#{template_name}.html.erb")
    template_content = File.read(template_path)#, "r").to_s
    
    # template_content = File.readlines(template_path, "r").to_s
    render_content(ERB.new(template_content).result(binding), "text/html")
  end

  # method exposing a `Session` object
  def session
    @session ||= Session.new(@req)
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
  end
end

