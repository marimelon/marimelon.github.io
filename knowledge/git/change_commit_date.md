# コミットの日時を変更する
GitコミットにはAuthorDateとCommitDateが存在するため両方を修正する必要がある

## 最初にCommitDateを編集する
### 直前のコミットを編集する

```sh
$ git commit --amend --date="2021-09-01T10:10:00+0900"
# 現在日時に設定
$ git commit --amend --date $(date --iso-8601=seconds)
```

### 複数のコミットを編集する
コミットを編集状態にする(先頭から3コミット)

```sh
$ git rebase -i HEAD~3
```

変更したいコミットをeditに変えて保存

```sh
  1 pick 7b92777 Second commit↲
  2 pick 1338ca6 Third commit↲
  3 pick a505b00 Fourth commit↲

## editモードにする

  1 edit 7b92777 Second commit↲
  2 edit 1338ca6 Third commit↲
  3 edit a505b00 Fourth commit↲
```

古いコミットから順に修正を行う

```sh
$ git commit --amend --date="2021-09-01T10:10:00+0900"
# 現在日時に設定
$ git commit --amend --date $(date --iso-8601=seconds)

# 次のコミットに移動
$ git rebase --continue
```

## AuthorDateを修正する
AuthorDateをCommitDateに合わせる

```sh
$ git rebase HEAD~3 --committer-date-is-author-date
```

## 確認

```sh
$ git log --pretty=fuller
```