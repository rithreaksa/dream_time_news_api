class Api::ArticlesController < ApplicationController
  before_action :authenticate_user!, only: %i[create]
  before_action :is_user_journalist?, only: %i[create]

  def create
    article = current_user.articles.create(article_params)
    if article.persisted? && attach_image(article)
      render json: { message: 'Your article was successfully created!' },
             status: 201
    else
      render json: { message: 'Something went wrong!' }
    end
  end

  def index
    articles = Article.all
    render json: articles, each_serializer: ArticlesIndexSerializer
  end

  def show
    article = Article.find(params[:id])
    render json: article, serializer: ArticlesShowSerializer
  rescue ActiveRecord::RecordNotFound => e
    render json: { message: 'No article found' }, status: 404
  end

  private

  def article_params
    params.require(:article).permit(:title, :sub_title, :content, :premium)
  end

  def is_user_journalist?
    unless current_user.journalist?
      render json: { message: 'You are not authorized to create an article.' },
             status: 401
    end
  end

  def attach_image(article)
    params_image = params[:article][:image]
      if params_image.present?
        DecodeService.add_attachment(params_image, article.image)
      end
  end
end
