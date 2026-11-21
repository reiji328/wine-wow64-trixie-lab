# Wine 11.0 新WoW64・Debian 13 検証用

Windows版LINEの自動化に向け、ナギのDebian13 (amd64) クラウドPCで32ビットWindowsアプリを動かすためのWine 11.0ビルド実験。公式ソースをSHA256照合し、32ビットLinuxの実行環境なしで動作する新WoW64を自前ビルドします。

**現段階：CIは未実行。Wine 11とLINEの成功は未確認。** この公開リポジトリにはログイン情報やLINEインストーラーを置きません。

## ビルドと成功判定
- GitHub Actionsの手動Run workflowのみ。自動push・定時実行はありません。
- 標準GitHubランナー上のdebian:trixieコンテナを使い、Wine公式11.0ソースを取得。SHA-256はc07a6857933c1fc60dff5448d79f39c92481c1e9db5aa628db9d0358446e0701に固定。
- コンパイルは --enable-archs=i386,x86_64。Linuxのi386環境は追加しません。
- インストール先はナギのPCと同じ /workspace/shared/line-wow64-11.0 に固定し、成果物を別のアーカイブとして保存します。
- i386-windows、x86_64-windows、x86_64-unixが存在しi386-unixがないことを検査し、PE32版cmd.exeでWOW64_OK・exit 0が確認できた場合だけ成果物をアップロード。
- 成功アーティファクトは7日間保持。署名・SHA256と配置先の検証後にだけナギへ導入します。

## iPhoneから実行
1. このGitHubリポジトリのActionsを開く。
2. Wine 11.0 new WoW64 - Debian 13 を開き、Run workflowを1回押す。
3. 実行ログで成功／最初の失敗原因を確認する。失敗したらCodex向けAGENTS.mdを参照して調整。
4. 成功したらwine11-wow64-debian13.tar.zstとSHA256SUMSを取得し、ナギの専用フォルダへ検証付きで展開する。
5. ナギのPCでも32ビットWindowsコマンドの正常実行を確認した後に限り、LINEインストーラーの初画面を検証する。

## 安全上の注意
公開リポジトリの標準GitHubランナー計算時間はGitHubの公開料金条件では無料です。大規模なWineビルドなので初回成功は保証できません。既存のWine10やUvoiceは変更しません。LINEのログイン、規約への同意、ポイント操作はまだ行いません。

## 出典
- Wine 11安定版の新WoW64：<https://list.winehq.org/hyperkitty/list/wine-releases@list.winehq.org/message/UL6L2GJ55VYUJ5KUMBZ3TZSXRFJ52QG6/>
- Wine公式11.0ソース：<https://dl.winehq.org/wine/source/11.0/wine-11.0.tar.xz>
- 新WoW64のビルド：<https://www.deepin.org/en/getting-started-with-wine/>
- GitHub Actions標準ランナー：<https://docs.github.com/en/actions/reference/runners/github-hosted-runners>
