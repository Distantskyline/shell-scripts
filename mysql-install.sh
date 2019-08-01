#!/usr/bin/env bash
#
# author: bavdu
# date: 2019/07/27
# encoding: utf8
# usage: auto deploy mysql tarball.

MPATH="/usr/local/mysqld"

# 改变拥有者和所属组,用来让mysql进程对该目录拥有读写权限
id mysql &>/dev/null
if [ $? -ne 0 ];then
	useradd -M -s /sbin/nologin mysql
fi
chown -R mysql:mysql /usr/local/mysqld

# 备份好系统自带的配置文件,把新的配置文件拷贝到/etc目录下
if [ -f /etc/my.cnf ];then
	mv /etc/my.cnf{,.bak}
fi
cp ${MPATH}/mysql/mysql-test/include/default_my.cnf /etc/my.cnf

# 提升mysql的自带命令为系统命令
echo 'export PATH=$PATH:/usr/local/mysqld/mysql/bin' >>/etc/profile

# 设置开机启动项及控制命令
if [ ! -f /etc/init.d/mysqld ];then
	cp ${MPATH}/mysql/support-files/mysql.server /etc/init.d/mysqld
	chkconfig --add mysqld && chkconfig mysqld on
	ln -s ${MPATH}/mysql/support-files/mysql.server /usr/bin/mysqlctl
fi

# 启动mysqld进程,并设置好socket套接字文件
ps aux | grep mysql | grep -v grep &>/dev/null
if [ $? -ne 0 ];then
	mysqlctl start
	ln -s ${MPATH}/tmp/mysql.sock /tmp/mysql.sock
fi

# 获取初始化密码
word=$(grep "temporary password" ${MPATH}/log/mysql_error.log)
word=$(grep "temporary password" ${MPATH}/log/mysql_error.log)
passwd=${word##*" "}


echo "Thank for you using bavduer's tools"
echo
echo "Email: bavduer@163.com"
echo "Github: https://github.com/bavdu"
echo
echo
echo "User: root"
echo "Password: ${passwd}"
echo "your first run command: source /etc/profile"
echo "Please update password, use ALTER USER root@localhost IDENTIFIED BY userPassword;"
echo
echo "Complete ^_~"
