# frozen_string_literal: true

class Comfy::Blog::PostsController < Comfy::Cms::BaseController

  include Comfy::Paginate

  def index
    scope =
      if params[:year]
        scope = @cms_site.blog_posts.published.for_year(params[:year])
        params[:month] ? scope.for_month(params[:month]) : scope
      else
        @cms_site.blog_posts.published
      end

    scope = scope.for_category(params[:category]) if params[:category]
    scope = scope.order(:published_at).reverse_order

    @blog_posts = comfy_paginate(scope, per_page: ComfyBlog.config.posts_per_page)
    render layout: ComfyBlog.config.app_layout
  end

  def show
    load_post

    render layout: app_layout

  rescue ActiveRecord::RecordNotFound
    render cms_page: "/404", status: 404
  end

private

  def load_post
    post_scope = @cms_site.blog_posts.published.where(slug: params[:slug])
    @cms_post = post_scope.first!
    @cms_layout = @cms_post.layout
  end

  def app_layout
    return false unless @cms_layout
    @cms_layout.app_layout.present? ? @cms_layout.app_layout : false
  end

end
