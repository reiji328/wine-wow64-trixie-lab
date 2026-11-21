# Codex向け開発ガイド

目的：Debian 13（Trixie）amd64上で、Linuxのi386 ELF実行環境を使わず、Wine 11.0 新WoW64をユーザー専用フォルダへ構築し、PE32版cmd.exeを実行する。

## 固定条件
- 既存Wine 10.0では64bit版Windowsメモ帳だけ成功。32bitネイティブLinuxローダーは Exec format error。32bit cmd.exeとLINE公式インストーラーは終了コード1。LINE固有の問題とは断定しない。
- GitHub Actionsはdebian:trixie、Wine 11.0公式ソースとSHA256を固定。構築オプションは --enable-archs=i386,x86_64。
- GitHub Actionsはworkflow_dispatchで手動実行だけ。秘密情報、LINEアカウント情報、LINEインストーラーをリポジトリやCIに置かない。
- ナギのクラウドPCのWine10/uvoiceを保持。新Wineの想定配置先は /workspace/shared/line-wow64-11.0。
- GitHub Actions成功条件はi386-windows、x86_64-windows、x86_64-unixの3ディレクトリがあり、i386-unixが無いこと。そして32bit Windows cmdでWOW64_OKを表示し終了コード0となること。
- Linux i386 runtimeや管理権限の回避を使わない。Debian TrixieのMinGW/binutilsの既知のWineビルド問題が出たらDebian正式パッチ・対象版を検証してから修正する。
- Wineのビルド成功とLINEの動作は別の判定。LINEセットアップはCI後にナギのPCで別に検証する。

## 失敗時の作業
1. 実際のGitHub Actionsログから最初の具体的な失敗原因を特定する。
2. scripts/の該当ファイルだけを最小限修正し、コミット履歴を残す。
3. 手動で一度だけ再実行し、cmdの出力とexit codeを確認する。
4. アーティファクト受け渡し時はSHA256と配置先を再確認する。
