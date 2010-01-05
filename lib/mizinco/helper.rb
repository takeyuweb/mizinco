# -*- coding: utf-8 -*-
module Mizinco
  module Helper
    # render :partial => 'entry'
    def render(name)
      @app.send(:render, name, self) # 実行中のコンテキストで他のテンプレートのコンパイル
    end

    def app_name
      @app.send(:config).app_name
    end
  end
end
