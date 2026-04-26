module Api
  module V1
    class ContentsController < ApplicationController
      before_action :authenticate_user!, except: [:index, :show]
      before_action :set_content, only: [:show, :update, :destroy, :publish, :versions, :revert]

      # GET /api/v1/contents
      def index
        @contents = if current_user&.admin?
                      Content.all
                    else
                      Content.published
                    end

        @contents = @contents.includes(:author)
                             .recent
                             .page(params[:page] || 1)
                             .per(params[:per_page] || 20)

        render_success(
          @contents.map { |content| content_response(content) },
          meta: pagination_meta(@contents)
        )
      end

      # POST /api/v1/contents
      def create
        @content = current_user.authored_contents.build(content_params)

        if @content.save
          render_success(content_response(@content), status: :created)
        else
          render_error(
            'コンテンツの作成に失敗しました',
            code: 'CONTENT_CREATE_FAILED',
            status: :unprocessable_entity,
            details: @content.errors.full_messages
          )
        end
      end

      # GET /api/v1/contents/:id
      def show
        authorize @content unless @content.published?
        render_success(content_response(@content))
      end

      # PUT /api/v1/contents/:id
      def update
        authorize @content

        if @content.update(content_params)
          render_success(content_response(@content))
        else
          render_error(
            'コンテンツの更新に失敗しました',
            code: 'CONTENT_UPDATE_FAILED',
            status: :unprocessable_entity,
            details: @content.errors.full_messages
          )
        end
      end

      # DELETE /api/v1/contents/:id
      def destroy
        authorize @content

        if @content.destroy
          render_success({ message: 'コンテンツを削除しました' })
        else
          render_error(
            'コンテンツの削除に失敗しました',
            code: 'CONTENT_DELETE_FAILED',
            status: :unprocessable_entity
          )
        end
      end

      # POST /api/v1/contents/:id/publish
      def publish
        authorize @content

        if @content.publish!
          render_success({
            message: 'コンテンツを公開しました',
            content: content_response(@content)
          })
        else
          render_error(
            'コンテンツの公開に失敗しました',
            code: 'CONTENT_PUBLISH_FAILED',
            status: :unprocessable_entity
          )
        end
      end

      # GET /api/v1/contents/:id/versions
      def versions
        authorize @content

        @versions = @content.content_versions.order(version_number: :desc)

        render_success(
          @versions.map { |version| version_response(version) }
        )
      end

      # POST /api/v1/contents/:id/revert
      def revert
        authorize @content

        version_number = params[:version_number].to_i

        if @content.revert_to_version(version_number)
          render_success({
            message: "バージョン#{version_number}に戻しました",
            content: content_response(@content.reload)
          })
        else
          render_error(
            'バージョンの復元に失敗しました',
            code: 'VERSION_REVERT_FAILED',
            status: :unprocessable_entity
          )
        end
      end

      private

      def set_content
        @content = Content.find(params[:id])
      end

      def content_params
        params.require(:content).permit(:title, :body, :status)
      end

      def content_response(content)
        {
          id: content.id,
          title: content.title,
          body: content.body,
          slug: content.slug,
          status: content.status,
          published_at: content.published_at,
          author: {
            id: content.author.id,
            display_name: content.author.profile&.display_name || content.author.email
          },
          versions_count: content.content_versions.count,
          created_at: content.created_at,
          updated_at: content.updated_at
        }
      end

      def version_response(version)
        {
          id: version.id,
          version_number: version.version_number,
          body: version.body,
          metadata: version.metadata,
          created_at: version.created_at
        }
      end

      def pagination_meta(collection)
        {
          current_page: collection.current_page,
          total_pages: collection.total_pages,
          total_count: collection.total_count,
          per_page: collection.limit_value
        }
      end
    end
  end
end
