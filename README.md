docker-build-tools
==================

# はじめに
dockerにてx86用ビルド環境を提供するコンテナです。  
sshdを内包しており、コンテナ起動時に設定した1ユーザでログインできます。  
コンテナはportがぶつからない限り、任意の数起動できます。  
jenkins-slaveとしての利用を想定し、javaとsshdをインストール済みです。

また、コンテナ内のファイルはホスト側からは隔離されます。永続的なファイルの保存が必要な場合は-vオプションを使用してホスト側のディレクトリをマウントしてください。

使い方
------
# Installation
以下のようにdocker imageをpullします。

    docker pull sharaku/build-tools

Docker imageを自分で構築することもできます。

    git clone https://github.com/sharaku/docker-build-tools.git
    cd docker-build-tools
    docker build --tag="$USER/build-tools" .

# Quick Start
build-toolsのimageを実行します。

    docker run -d -e "LOGIN_USER=login_user:login_user_passwd" -p 10022:22 sharaku/build-tools

sshdの代わりに/bin/bashで起動することもできます。
この場合、rootユーザでのログインとなります。

    docker run -it sharaku/build-tools /bin/bash

## Argument

+   `-v /path/to/data:/path/to/container/data:rw` :  
    永続的に保存するデータのディレクトリを指定します。任意の数の-vオプションを使用可能です。

+   `-e "LOGIN_USER=login_user:login_user_passwd"` :  
    ログインするユーザ名、パスワードを":"で区切って指定します。  
    例：-e "LOGIN_USER=hogehoge:hogehoge-passwd"

+   -p port:22 :  
    外部公開するポートを設定します。

# Installed environment
build-toolsコンテナには以下がインストール済みです。

base:debian 7.6

servers:

      sshd

build tools:

      build-essential, libtool, ncurses-dev, kmod, libproc-processtable-perl, uboot-mkimage, cppcheck

tools:

      wget, git, vim, bzip2, nkf, unzip, bc, default-jdk

利用例
------

# build-tools
スタンダードなbuild-toolsとして使用するには以下のようにします。

以下の条件でbuild-toolsを構築する例です。

+ ユーザ名：hogehoge
+ パスワード：hogehoge-passwd
+ ポート：10022
+ ボリューム（ホスト側）：/var/lib/build-volume
+ ボリューム（コンテナ側）：/var/lib/volume

　

      mkdir /var/lib/build-volume

      docker run -d \
        -v /var/lib/build-volume:/var/lib/volume:rw \
        -e "LOGIN_USER=hogehoge:hogehoge-passwd" \
        -p 10022:22 sharaku/build-tools


# jenkins-slave
jenkins-slaveとして使用するには以下のようにします。

+ ユーザ名：jenkins
+ パスワード：jenkins###
+ jenkinsポート：8080
+ ポート(内部利用)：10022
+ ボリューム（ホスト側）：/var/lib/jenkins-volume
+ ボリューム（コンテナ側）：/var/lib/jenkins

手順

1.ビルド環境の保存領域を作成します  

      mkdir /var/lib/jenkins-volume

2.sharaku/build-toolsコンテナを起動します。  

      docker run -d \
        -v /var/lib/jenkins-volume:/var/lib/jenkins:rw \
        -e "LOGIN_USER=jenkins:jenkins###" \
        -p 10022:22 sharaku/build-tools

3.jenkinsを起動し、設定を行います。  

      docker run -d -p 8080:8080 jenkins

4.ブラウザから、jenkinsへ接続します。  
5.jenkinsのメニューから `Jenkinsの管理 -> ノードの管理 -> 新規ノード作成` を開きます。  
6. `ノード名` を入力後、`ダムスレーブ` にチェックを入れ、`OK`を押します。  
7.`リモートFSルート`は"/var/lib/jenkins"を入力します。  
8.`起動方法`は"ssh経由で～"を選択します。  
9.`ホスト`はホストのIPもしくは、ドメインを指定します。  
10.`認証情報`は`add`を押し、ユーザ名とパスワードを設定します。  
11.`高度な設定`を押し、`ポート`の欄に10022を指定します。  
12.`保存`を押します。

以上で接続ができるようになります。
