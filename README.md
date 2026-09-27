# vault-rules

Obsidian Vault（ローカル）のうち、**公開してよいルール類だけ**を切り出した公開ミラー。

スマホの Claude や ChatGPT の通常チャットからローカルファイルは読めないため、
このリポジトリの raw URL を読ませることで、**どの端末・どのAIからでも同じルールで動かす**ことを目的とする。

## 原本はここではない

**編集は必ず `D:\Vault` 側で行う。** このリポジトリの中身は `sync.ps1` によって毎回上書きされるため、
ここで直接編集しても次の同期で消える。

## 更新のしかた

Vault のルールを変更したら、PowerShell で実行する。

```powershell
D:\vault-rules\sync.ps1
```

コピー → commit → push までを一度に行う。変更がなければ何もしない。

## 公開しているもの

| ファイル | 内容 |
| :---- | :---- |
| `CLAUDE.md` | 全体の行動ルール |
| `MISTAKES.md` | 領域横断の誤り記録 |
| `10_Specialists/camera/` | カメラ領域のルール・機材・誤り記録 |
| `10_Specialists/korean/` | 韓国語領域のルール・学習状況・誤り記録 |
| `10_Specialists/dev/CLAUDE.md` | 開発領域のルール |
| `10_Specialists/dev/MISTAKES.md` | 開発領域の誤り記録 |

## 公開していないもの

個人情報・案件情報・機材の詳細環境が含まれるため、以下は同期対象外。

- ルート `MEMORY.md`（経歴・家族構成・稼働状況）
- `10_Specialists/clients/` 配下すべて（案件情報）
- `10_Specialists/dev/MEMORY.md`（PC構成・実機ID・ツール一覧）
- `10_Specialists/dev/projects/`、`dev/notes/`
- `20_Resources/`、`90_Archive/`、`00_Inbox/`、`techbiz/`

公開範囲を変えるときは `sync.ps1` の `$Files` を編集する。
