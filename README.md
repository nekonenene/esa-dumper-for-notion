# esa Dumper for Notion

[esa](https://esa.io) → [Notion](https://www.notion.so) への移行作業をするにあたって、  
Notion のインポートは、 **1フォルダ内に HTML ないしはマークダウンファイルをまとめていないと一度におこなえない** という  
つらい仕様があったので作成しました。（今後 zip ファイルをアップロードできるなどいい感じになってほしい……）

各記事と、それに紐づくコメントをまとめて HTML とマークダウンの両方で出力します。  
Notion へのインポートには HTML を使うのがおすすめです。  
（Notion のマークダウンインポートは GitHub Flavored Markdown として解釈しないため、改行やリンクなどが無くなる）

もしくは、GitHub Flavored Markdown を解釈しつつ HTML に変換するライブラリを使って、  
マークダウンを HTML に変換してからインポートするという手もあります。試していないですが、そっちの方がより正確かも。

## 使い方

```sh
cp default.env .env
```

をおこなったあと `ESA_TEAM_NAME` に `<teamname>.esa.io` の teamname の部分を、  
`ESA_ACCESS_TOKEN` に esa のパーソナルアクセストークンを設定します。（READ権限だけで大丈夫です）

あとは

```sh
bundle install
```

をおこなって依存ライブラリをインストールしたあと、

```sh
bundle exec ruby main.rb
```

をおこなえば完了です。 `export` ディレクトリにファイルが出力されます。


## 注意事項

esa は特に連絡をしない限り、APIの利用制限が15分に75リクエストまでとなっていますので、  
記事合計数が 7500 を超えている場合は途中で Too Many Requests エラーが起こってしまいます。

参照: https://docs.esa.io/posts/102#%E5%88%A9%E7%94%A8%E5%88%B6%E9%99%90

制限緩和のリクエストを esa のサポートにおこなうか、  
何ページ目から始めるかを、以下のように引数で指定するとよいでしょう。

```sh
bundle exec ruby main.rb 10
```
