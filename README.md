#  RxInstaSample

このプロジェクトはInstagramのような写真投稿アプリをFirebase+RxSwiftで実装したサンプルです。

次のような機能要素を実装しています。

1. アカウント作成、ログイン、ログアウト
2. ユーザー名変更
3. 投稿写真の一覧表示
4. カメラで撮影した写真を直接投稿
5. ライブラリの中から選択した写真を投稿
6. 写真の加工(クリッピング、回転、文字入れ等々)
7. いいねボタン

次のような技術要素を盛り込んでいます。

1. Firebase(FireStore, Storage, Authentication)使用
2. RxSwift使用
3. MVVMアーキテクチャで構成
4. StoryBoardは画面毎に独立させ、画面間はStoryBoardReferenceで接続
5. ViewModelの単体テストコード作成(ModelをMock化してDIし、RxTestを使用してテスト)

(参考文献)
------------------------
- [RxSwiftライブラリ提供元公式ページ(GitHub)](https://github.com/ReactiveX/RxSwift)
- [RxSwift研究読本1 入門編](https://booth.pm/ja/items/1076262 )
- [RxSwift研究読本3 ViewModel設計パターン入門編](https://swift.booth.pm/items/1223536)
- その他多数のWebサイト記事

(アプリ起動方法)
------------------------
1. ターミナルでpod installを実施して使用ライブラリをインストール
2. Firebaseにプロジェクトを作成し、次の機能の使用を開始する
3. Authentication(email)の使用 → メール/パスワードログインを有効
4. FireStore、Storageの使用 → セキュリティルールは、ログイン済みの場合のみ読み書き可
5. GoogleServiceInfo.plistをFirebaseのサイトからダウンロードし、本プロジェクトに組み込み
6. アプリを起動(カメラを使用するには実機が必要)
