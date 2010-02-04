# -*- coding: utf-8 -*-
module Mizinco
  module Helper
    # render :partial => 'entry'
    def render(name)
      @app.send(:render, name, self) # 実行中のコンテキストで他のテンプレートのコンパイル
    end

    def app_name
      config.app_name
    end

    def params
      @app.send(:params).clone
    end

    def config
      @app.send(:config).clone
    end
  end
end
