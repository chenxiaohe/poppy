RHCE练习题和参考解答
##############################


环境说明
================

真实机（无 root 权限）：foundation.groupX.example.com

虚拟机 1（有 root 权限）：system1.groupX.example.com

虚拟机 2（有 root 权限）：system2.groupX.example.com

考试服务器（提供 DNS/YUM/认证/素材	）：server1.groupX.example.com、host.groupX.example.com

练习环境说明
==================

真实机（无 root 权限）：foundationX.example.com

虚拟机 1（有 root 权限）：serverX.example.com

虚拟机 2（有 root 权限）：desktopX.example.com

练习服务器（提供 DNS/YUM/认证/素材.. ..）：http://classroom.example.com

example.com,group0.example.com: 172.25.0.0/24

alv.pub:    172.24.3.0/24

上面描述的主机名即域名，访问该域名可以解析到相应的IP地址，上述域名中的X,代表服务器编号，比如我的服务器编号是3，那么我的server端的域名就是server3.example.com ，ip地址也是在172.25.3.0/24网段。

下面的实验中，我的练习环境是使用的172.25.0.0/24网段，使用的编号是0，所以我使用的域名也是server0.example.com， desktop0.example.com， 如果实际你练习或考试使用的网段是其他网段，比如14网段，那就改成server14.server0.com，这里我再重复了一遍。

注意事项
===========

一定要等classroom完全启动完了，再启动desktop和server。

配置 SELinux
=================

试题概述：

确保 SELinux 处于强制启用模式。

::

    setenforce 1 #开启selinux
    sed -i 's/SELINUX=.*/SELINUX=enforcing/ /etc/selinux/config #通过配置文件永久开启selinux。


配置 SSH 访问试题概述：
===========================

按以下要求配置 SSH 访问：

- 用户能够从域 group0.example.com 内的客户端 SSH 远程访问您的两个虚拟机系统
- 在域 alv.pub 内的客户端不能访问您的两个虚拟机系统

.. code-block:: bash

    echo "sshd : 172.25.0.0/24" >> /etc/hosts.allow
    echo "sshd : 172.24.3.0/24" >> /etc/hosts.deny



自定义用户环境（别名设置） 试题概述：
==============================================


在系统 server0 和 desktop0 上创建自定义命令为 qstat，此自定义命令将执行以下命令：

/bin/ps -Ao pid,tt,user,fname,rsz 此命令对系统中所有用户有效。

参考解答：

.. code-block:: bash

    echo "alias qtast='/bin/ps -Ao pid,tt,user,fname,rsz'" >> /etc/bashrc
    source /etc/bashrc
    qsast


配置防火墙端口转发试题概述：
==============================================

在系统 server0 配置端口转发，要求如下：

- 在 172.25.0.0/24 网络中的系统，访问 server0 的本地端口 5423 将被转发到 80

- 此设置必须永久有效

[注：推荐 firewall-config 图形配置工具]

.. code-block:: bash

    firewall-cmd --add-forward-port='port=5423:proto=tcp:toport=80' --permanent
    firewall-cmd --reload

配置链路聚合试题概述：
==============================================

在server0和 desktop0 之间按以下要求配置一个链路：

- 此链路使用接口 eth1 和 eth2
- 此链路在一个接口失效时仍然能工作；
- 此链路在 server0 使用下面的地址 172.16.0.20/255.255.255.0
- 此链路在 dekstop0 使用下面的地址 172.16.0.25/255.255.255.0
- 此链路在系统重启之后依然保持正常状态

.. note::

    创建tem0的时候，编写config的时候，那段json的最外层一定要用单引号'', 例如： '{"runner":{"name":"activebackup"}}'， 如果是外层是双引号"" 里面是单引号，后面slave会识别不到这个master的，connection up时会报错的。


system1:

.. code-block:: bash
    :linenos:

    ##建立新的聚合连
    nmcli connection add con-name team0 type team ifname team0 config '{"runner":{"name":"activebackup"}}'
    ##指定成员网卡 1
    nmcli connection add con-name team0-p1 type team-slave ifname eth1 master team0
    ##指定成员网卡 2
    nmcli connection add con-name team0-p2 type team-slave ifname eth2 master team0
    ##为聚合连接配置 IP 地址
    nmcli  connection modify team0 ipv4.method manual ipv4.address "172.16.0.20/24"
    ##激活聚合连
    nmcli connection up team0
    ## 激活成员连接1（备用)
    nmcli connection up team0-p1
    ## 激活成员连接 2（备用)
    nmcli connection up team0-p2
    teamdctl team0 state

system2:



.. code-block:: bash
    :linenos:

    ##建立新的聚合连
    nmcli connection add con-name team0 type team ifname team0 config '{"runner":{"name":"activebackup"}}'
    ##指定成员网卡 1
    nmcli connection add con-name team0-p1 type team-slave ifname eth1 master team0
    ##指定成员网卡 2
    nmcli connection add con-name team0-p2 type team-slave ifname eth2 master team0
    ##为聚合连接配置 IP 地址
    nmcli  connection modify team0 ipv4.method manual ipv4.address "172.16.0.25/24"
    ##激活聚合连
    nmcli connection up team0
    ## 激活成员连接1（备用)
    nmcli connection up team0-p1
    ## 激活成员连接 2（备用)
    nmcli connection up team0-p2
    teamdctl team0 state



配置 IPv6 地址试题概述：
==============================================

在您的考试系统上配置接口 eth0 使用下列 IPv6 地址：

- server0 上的地址应该是 2003:ac18::305/64
- desktop0 上的地址应该是 2003:ac18::306/64
- 两个系统必须能与网络 2003:ac18/64 内的系统通信
- 地址必须在重启后依旧生效
- 两个系统必须保持当前的 IPv4 地址并能通信


参考解答：


server0

.. code-block:: bash

    nmcli connection modify "eth0" ipv6.method  manual ipv6.address 2003:ac18::305/64 ifname eth0
    nmcli connection up "eth0"

desktop0

.. code-block:: bash

    nmcli connection modify "eth0" ipv6.method  manual ipv6.address 2003:ac18::305/64 ifname eth0
    nmcli connection up "eth0"


配置本地邮件服务试题概述：
==============================================

在系统 server0 和 desktop0 上配置邮件服务，满足以下要求：

- 这些系统不接收外部发送来的邮件
- 在这些系统上本地发送的任何邮件都会自动路由到 smtp0.example.com
- 从这些系统上发送的邮件显示来自于 desktop0.example.com
- 您可以通过发送邮件到本地用户student来测试您的配置，系统
- smtp0.example.com	已经配置把此用户的邮件转到下列URL：http://smtp0.example.com/received_mail/3

- 解题参考：

[练习环境：lab smtp-nullclient setup] server和desktop都执行这个，

.. note::

    #. 我们的练习环境下,一定要在server和desktop端都先执行 lab smtp-nullclient setup，否则会报错的。
    #. relayhost 指定的是邮件被路由到的服务器。
    #. inet_interfaces 是用于控制Postfix侦听传入电子邮件的网络接口。如果设置为loopback-only,仅侦听127.0.0.1和::1。如果设置为all,则侦听所有网络接口。还可以指定特定地址。 默认:inet_interfaces = localhost
    #. myorigin 用于重写本地发布的电子邮件,使其显示为来自该域。这样有助于确保响应返回入站邮件服务器,默认:myorigin = $myhostname
    #. mydestination  收到地址为这些域的电子邮件将传递至MDA,以进行本地发送。默认:mydestination = $myhostname, localhost.$mydomain, localhost， "mydestination=" 不发送到本地，而空客户端将所有邮件发送到中继器
    #. mynetworks IP地址和网络的逗号分隔列表(采用CIDR表示法)。这些地址和网络可以通过此MTA转发至任何位置,无需进一步身份验证。 默认:mynetworks = 127.0.0.0/8
    #. local_transport = error:local delivery disabled 空客户端拒绝接收任何邮件

server端：

.. code-block:: bash

    # lab smtp-nullclient setup
    # vim /etc/postfix/main.cf
    relayhost=[smtp0.example.com]
    inet_interfaces = loopback-only
    myorigin = desktop0.example.com
    mynetworks = 127.0.0.0/8 [::1]/128
    local_transport = error:local delivery disabled
    mydestination =

    # systemctl restart postfix
    # systemctl enable postfix
    # firewall-cmd --add-service=smtp
    # firewall-cmd --reload

然后在desktop0 执行 lab smtp-nullclient setup

然后继续在server0执行

.. code-block:: bash

    # echo 'Mail Data.' |mail -s 'Test1' student

然后去desktop0验证

.. code-block:: bash

    # mail -u student

.. note::

    上面是交互式操作，上面的内容也可以替换为下面的非交互式配置邮件服务，可直接复制粘贴一键完成

    先在desktop0执行:

        .. code-block:: bash

            lab smtp-nullclient setup

    因为desktop上环境准备好了，server才能把邮件发过来。


    然后在server0执行:

        .. code-block:: bash

            lab smtp-nullclient setup
            echo '
            relayhost=[smtp0.example.com]
            inet_interfaces = loopback-only
            myorigin = desktop0.example.com
            mynetworks = 127.0.0.0/8 [::1]/128
            local_transport = error:local delivery disabled
            mydestination =
            ' >> /etc/postfix/main.cf
            systemctl restart postfix
            systemctl enable postfix
            firewall-cmd --add-service=smtp
            firewall-cmd --reload
            echo 'Mail Data.' |mail -s 'Test1' student
            echo 'done'

    最后在desktop端验证，看邮件有没有收到：

        .. code-block:: bash

            mail -u student




通过 Samba 发布共享目录试题概述：
==============================================

在 system1 上通过 SMB 共享/common 目录：

- 您的 SMB 服务器必须是 STAFF 工作组的一个成员
- 共享名必须为 common
- 只有 group0.example.com 域内的客户端可以访问 common 共享
- common 必须是可以浏览的
- 用户 harry 必须能够读取共享中的内容，如果需要的话，验证的密码是 redhat


- 解题参考：

.. code-block:: bash

    yum install samba -y
    mkdir -p /common
    setsebool -P samba_export_all_rw=on  ##取消selinux限制
    semanage fcontext -a -t samba_share_t '/common(/.*)?'
    restorecon -R /common/
    useradd harry ； pdbedit -a harry ##启用共享账号并设置redhat
    vim /etc/samba/smb.conf
    [global]
        workgroup = STAFF
    [common]
        path = /common
        hosts allow = 172.25.0.0/24

    systemctl restart smb nmb
    systemctl enable smb nmb
    firewall-cmd --permanent --add-service=samba
    firewall-cmd --reload
    echo 'done'


.. note::

    上面是交互式操作，上面的内容也可以替换为下面的非交互式配置samba，可直接复制粘贴一键完成

    ::

        yum install samba expect -y >/dev/null
        mkdir -p /common
        semanage fcontext -a -t samba_share_t '/common(/.*)?'
        restorecon -R /common/
        setsebool -P samba_export_all_rw=on  ##取消selinux限制
        useradd harry;
        expect <<eof
        spawn pdbedit -a harry
        expect "password:"
        send "redhat\n"
        expect "new password:"
        send "redhat\n"
        expect eof
        eof
        sed -i 's/MYGROUP/STAFF/' /etc/samba/smb.conf
        echo '
        [common]
            path = /common
            hosts allow = 172.25.0.0/24
        ' >> /etc/samba/smb.conf
        systemctl restart smb nmb
        systemctl enable smb nmb
        firewall-cmd --permanent --add-service=samba
        firewall-cmd --reload
        echo 'done'

- 客户端验证

    在desktop0上操作

.. code-block:: bash

    yum install samba-client cifs-utils -y >/dev/null
    mkdir -p /common
    mount //server0/common /common -o user=harry,password=redhat
    [ $? -eq 0 ] && df /common && echo 'success' || echo 'failed!'
    echo 'done'



配置多用户 Samba 挂载试题概述：
==============================================

在 system1 通过 SMB 共享目录/devops，并满足以下要求：

- 共享名为 devops
- 共享目录 devops 只能被 groupX.example.com 域中的客户端使用
- 共享目录 devops 必须可以被浏览
- 用户 kenji 必须能以读的方式访问此共享，该问密码是 redhat
- 用户 chihiro 必须能以读写的方式访问此共享，访问密码是 redhat
- 此共享永久挂载在 desktop0.groupX.example.com 上的/mnt/dev 目录，并使用用户kenji 作为认证，任何用户可以通过用户 chihiro 来临时获取写的权限


解题参考：

.. code-block:: bash

    [root@serverX ~]# mkdir /devops
    [root@serverX ~]# useradd kenji ; pdbedit -a kenji
    [root@serverX ~]# useradd chihiro; pdbedit -a chihiro
    [root@serverX ~]# setfacl -m u:chihiro:rwx /devops/
    [root@serverX ~]# semanage fcontext -a -t samba_share_t '/devops(/.*)?'
    [root@serverX ~]# restorecon -R /devops/
    [root@serverX ~]# vim /etc/samba/smb.conf
    [devops]
        path = /devops
        write list = chihiro
        valid users = kenji,chihiro
        hosts allow = 172.25.0.0/24 //只允许指定网域访问
    [root@serverX ~]# systemctl restart smb


.. note::

    上面是交互式操作，上面的内容也可以替换为下面的非交互式一键命令：

    ::

        yum install samba expect -y &>/dev/null
        mkdir /devops
        useradd kenji
        useradd chihiro
        setfacl -m u:chihiro:rwx /devops/
        setfacl -m u:chihiro:rwx /devops/
        semanage fcontext -a -t samba_share_t '/devops(/.*)?'
        restorecon -R /devops/
        expect <<eof
        spawn pdbedit -a kenji
        expect "password:"
        send "redhat\n"
        expect "new password:"
        send "redhat\n"
        expect eof
        eof
        expect <<eof
        spawn pdbedit -a chihiro
        expect "password:"
        send "redhat\n"
        expect "new password:"
        send "redhat\n"
        expect eof
        eof
        echo '
        [devops]
            path = /devops
            write list = chihiro
            valid users = kenji,chihiro
            hosts allow = 172.25.0.0/24
        ' >> /etc/samba/smb.conf
        firewall-cmd --permanent --add-service=samba
        firewall-cmd --reload
        systemctl restart smb nmb
        systemctl enable smb nmb
        echo 'done'

然后在客户端desktop0上:

.. code-block:: bash

    [root@desktopX ~]# yum -y install samba-client cifs-utils >/dev/null
    [root@desktopX ~]# mkdir -p /mnt/dev
    [root@desktopX ~]# vim /etc/fstab
    //server0.example.com/devops    /mnt/dev    cifs username=kenji,password=redhat,multiuser,sec=ntlmssp,_netdev 0 0
    [root@desktopX ~]# mount -a

.. note::

    上面是交互式操作，上面的内容也可以替换为下面的非交互式一键执行命令：

    .. code-block:: bash

        yum -y install samba-client cifs-utils &>/dev/null
        mkdir -p /mnt/dev
        echo '//server0.example.com/devops    /mnt/dev    cifs username=kenji,password=redhat,multiuser,sec=ntlmssp,_netdev 0 0' >> /etc/fstab
        mount -a
        df
        echo 'done'


验证多用户访问（在 desktop0 上）：chihiro 可读写，

.. code-block:: bash

    yum install expect -y >/dev/null
    useradd user1
    su - user1
    touch /mnt/dev/alvin  #确认当前没有权限
    expect <<eof
    spawn cifscreds add -u chihiro server0
    expect "Password:"
    send "redhat\n"
    expect eof
    eof
    sleep 4
    touch /mnt/dev/alvin  #确认当前是否有权限
    ll /mnt/dev/alvin



配置 NFS 共享服务试题概述：
==============================================


在 system1 配置 NFS 服务，要求如下：

- 以只读的方式共享目录/public，同时只能被 group0.example.com 域中的系统访问
- 以读写的方式共享目录/securenfs，能被 group0.example.com 域中的系统访问
- 访问/protected 需要通过 Kerberos 安全加密，您可以使用下面 URL 提供的密钥： http://classroom.example.com/pub/keytabs/server0.keytab
- 目录/protected 应该包含名为 project 拥有人为 ldapuser0 的子目录
- 用户 ldapuser0 能以读写方式访问/protected/project

server0:

.. code-block:: bash

    [root@server0 ~]# lab nfskrb5 setup   #练习环境
    [root@server0 ~]# mkdir /public
    [root@server0 ~]# mkdir -p /protected/project
    [root@server0 ~]# chown ldapuser0 /protected/project
    [root@server0 ~]# vim /etc/exports
    /public 172.25.0.0/24(ro,sync)
    /protected 172.25.0.0/24(rw,sync,sec=krb5p)
    [root@server0 ~]# wget -O /etc/krb5.keytab http://classroom.example.com/pub/keytabs/server0.keytab
    [root@server0 ~]# vim /etc/sysconfig/nfs
    RPCNFSDARGS="-V 4.2"
    [root@server0 ~]# firewall-cmd --permanent --add-service=nfs
    success
    [root@server0 ~]# firewall-cmd --permanent --add-service=mountd
    success
    [root@server0 ~]# firewall-cmd --permanent --add-service=rpc-bind
    success
    [root@server0 ~]# firewall-cmd --reload
    success
    [root@server0 ~]# systemctl restart nfs-server nfs-secure-server
    [root@server0 ~]# systemctl enable nfs-server nfs-secure-server
    [root@server0 ~]# exportfs -ra
    [root@server0 ~]# showmount -e
    Export list for server0.example.com:
    /protected 172.25.0.0/24
    /public 172.25.0.0/24


.. note::

    上面是交互式操作，上面的内容也可以替换为以下命令，复制粘贴一次性全部完成

    .. code-block:: bash

        lab nfskrb5 setup
        mkdir /public
        mkdir -p /securenfs/project
        chown ldapuser0 /protected/project
        echo '/public 172.25.0.0/24(ro,sync)' > /etc/exports
        echo '/securenfs 172.25.0.0/24(rw,sync,sec=krb5p)' >> /etc/exports
        wget -q -O /etc/krb5.keytab http://classroom.example.com/pub/keytabs/server0.keytab
        sed  -i 's/RPCNFSDARGS=.*/RPCNFSDARGS="-V 4.2"/' /etc/sysconfig/nfs
        firewall-cmd --permanent --add-service=nfs
        firewall-cmd --permanent --add-service=mountd
        firewall-cmd --permanent --add-service=rpc-bind
        firewall-cmd --reload
        systemctl enable nfs-server nfs-secure-server
        systemctl start nfs-server nfs-secure-server
        echo 'done'

挂载 NFS 共享试题概述：
==============================================

在 desktop0 上挂载一个来自 server0.example.com 的共享，并符合下列要求：

- /public 挂载在下面的目录上/mnt/nfsmount
- /protected 挂载在下面的目录上/mnt/nfssecure 并使用安全的方式，密钥下载 URL： http://classroom.example.com/pub/keytabs/desktop0.keytab
- 用户 ldapuser0 能够在/mnt/nfssecure/project 上创建文件
- 这些文件系统在系统启动时自动挂载

ldapuser0的密码是 kerberos

desktop0:

.. code-block:: bash

    [root@desktop0 ~]# lab nfskrb5 setup  #练习环境
    [root@desktop0 ~]# showmount -e 172.25.0.11
    Export list for 172.25.0.11:
    /protected 172.25.0.0/24
    /public 172.25.0.0/24
    [root@desktop0 ~]# wget -O /etc/krb5.keytab http://classroom.example.com/pub/keytabs/desktop0.keytab
    [root@desktop0 ~]# systemctl restart nfs-secure
    [root@desktop0 ~]# systemctl enable nfs-secure
    ln -s '/usr/lib/systemd/system/nfs-secure.service' '/etc/systemd/system/nfs.target.wants/nfs-secure.service'
    [root@desktop0 ~]# mkdir -p /mnt/nfsmount
    [root@desktop0 ~]# mkdir -p /mnt/nfssecure
    [root@desktop0 ~]# vim /etc/fstab
    172.25.0.11:/public /mnt/nfsmount nfs defaults,_netdev 0 0
    172.25.0.11:/securenfs /mnt/secureshare nfs defaults,sec=krb5p,v4.2,_netdev 0 0
    [root@desktop0 ~]# mount -a
    [root@desktop0 ~]# df -Th
    [root@desktop0 ~]# su - ldapuser0   #验证ldapuser0的权限 使用root切换用户时是无法访问/mnt/nfssecure的。需要再su - ldaouser0一次，使用密码登录，才能访问/mnt/nfssecure/project
    [ldapuser0@desktop0 ~]$ ls /mnt/nfssecure/project
    [ldapuser0@desktop0 ~]$ su - ldapuser0
    [ldapuser0@desktop0 ~]$ touch /mnt/nfssecure/project/alvin

.. note::

    上面是交互式操作，上面的内容也可以替换为以下命令，复制粘贴一次性全部完成

    ::

        lab nfskrb5 setup
        wget -q -O /etc/krb5.keytab http://classroom.example.com/pub/keytabs/desktop0.keytab
        systemctl enable nfs-secure
        systemctl start nfs-secure
        mkdir -p /mnt/{nfsmount,nfssecure}
        echo 'server0:/public /mnt/nfsmount nfs defaults,_netdev 0 0' >> /etc/fstab
        echo 'server0:/protected /mnt/nfssecure nfs defaults,_netdev,sec=krb5p,v4.2 0 0' >> /etc/fstab
        mount -a
        df
        echo 'done'


实现一个 web 服务器试题概述：
==============================================

为 http://server0.example.com 配置 Web 服务器：

- 从http:/classroom.example.com/materials/station.html 下载一个主页文件，并将该文件重命名为 index.html
- 将文件 index.html 拷贝到您的 web 服务器的 DocumentRoot 目录下
- 不要对文件 index.html 的内容进行任何修改
- 来自于 group0.example.com 域的客户端可以访问此 Web 服务
- 来自于 alv.pub 域的客户端拒绝访问此 Web 服务


server0:

.. code-block:: bash

    [root@server0 httpd-2.4.6]# yum install -y httpd
    [root@server0 httpd-2.4.6]# cp /usr/share/doc/httpd-2.4.6/httpd-vhosts.conf /etc/httpd/conf.d/
    [root@server0 ~]# vim /etc/httpd/conf.d/httpd-vhosts.conf
    <VirtualHost *:80>
    DocumentRoot /var/www/html
    ServerName server0.example.com
    </VirtualHost>
    [root@server0 ~]# cd /var/www/html/
    [root@server0 html]# wget -O index.html http://rhgls.domain1.example.com/materials/server.html
    [root@server0 html]# ls index.html
    [root@server0 html]# cat index.html
    server.example.com.
    [root@server0 ~]# systemctl restart httpd
    [root@server0 ~]# systemctl enable httpd
    ln -s '/usr/lib/systemd/system/httpd.service' '/etc/systemd/system/multi-user.target.wants/httpd.service'
    [root@server0 ~]# firewall-cmd --permanent --add-rich-rule="rule family="ipv4" source address="172.24.3.0/24" reject"
    [root@server0 ~]# firewall-cmd --permanent --add-service=http success
    [root@server0 ~]# firewall-cmd --permanent --add-service=https success
    [root@server0 ~]# firewall-cmd --reload success

    desktop0:
    验证

    [root@desktop0 ~]# firefox



配置安全 web 服务试题概述：
==============================================


为站点 http://server0.example.com 配置TLS 加密

- 一个已签名证书从http://classroom/pub/tls/certs/www0.crt获取
- 此证书的密钥从http://classroom/pub/tls/private/www0.key获取
- 此证书的签名授权信息http://classroom/pub/example-ca.crt获取

server0:

.. code-block:: bash

    [root@server0 html]# yum install -y mod_ssl
    [root@server0 html]# vim /etc/httpd/conf.d/ssl.conf
    <VirtualHost _default_:443>
    # General setup for the virtual host, inherited from global configuration
    DocumentRoot "/var/www/html"
    ServerName server0.example.com:443
    SSLEngine on
    SSLProtocol all -SSLv2
    SSLCipherSuite HIGH:MEDIUM:!aNULL:!MD5
    SSLHonorCipherOrder on
    SSLCertificateFile /etc/pki/tls/certs/localhost.crt
    SSLCertificateKeyFile /etc/pki/tls/private/localhost.key
    SSLCertificateChainFile /etc/pki/tls/certs/server-chain.crt
    </VirtualHost>
    [root@server0 tls]# cd /etc/pki/tls/certs/
    [root@server0 certs]# wget -O localhost.crt http://classroom/pub/tls/certs/www0.crt
    [root@server0 certs]# cd /etc/pki/tls/private/
    [root@server0 private]# wget -O localhost.key http://classroom/pub/tls/private/www0.key
    [root@server0 private]# cd /etc/pki/tls/certs/
    [root@server0 certs]# wget -O server-chain.crt http://classroom/pub/example-ca.crt
    [root@server0 ~]# systemctl restart httpd.service
    [root@server0 ~]# systemctl enable httpd.service

desktop0:

 验证

.. code-block:: bash


    [root@desktop0 ~]# curl -k server0.example.com


配置虚拟主机试题概述：
==============================================

在 system1 上扩展您的 web 服务器，为站点 http://www0.example.com 创建一个虚拟主机，然后执行下述步骤：

- 设置 DocumentRoot 为/var/www/virtual
- 从 http://classroom.example.com/materials/www.html 下载文件并重命名为index.html
- 不要对文件 index.html 的内容做任何修改
- 将文件 index.html 放到虚拟主机的 DocumentRoot 目录下
- 确保 harry 用户能够在/var/www/virtual 目录下创建文件

注意：原始站点 server0.example.com 必须仍然能够访问，名称服务器classroom.example.com 提供对主机名 www0.example.com 的域名解析。



server0:

.. code-block:: bash

    [root@server0 ~]# mkdir -p /var/www/virtual
    [root@server0 ~]# ls -Zd /var/www/html/
    drwxr-xr-x. root root system_u:object_r:httpd_sys_content_t:s0 /var/www/html/
    [root@server0 ~]# chcon -R -t httpd_sys_content_t /var/www/virtual
    [root@server0 ~]# vim /etc/httpd/conf.d/httpd-vhosts.conf
    <VirtualHost *:80>
    DocumentRoot /var/www/virtual
    ServerName www0.example.com
    </VirtualHost>
    [root@server0 ~]# cd /var/www/virtual/
    [root@server0 virtual]# wget -O index.html http://classroom.example.com/materials/www.html
    [root@server0 virtual]# cat index.html
    www.example.com.
    [root@server0 virtual]# cd
    [root@server0 ~]# setfacl -m u:harry:rwx /var/www/virtual
    [root@server0 ~]# systemctl restart httpd.service

desktop0:

.. code-block:: bash

    [root@desktop0 ~]# firefox

配置 web 内容的访问
=========================

描述：

在 server0 上的 web 服务器的 DocumentRoot 目录下创建一个名为 secret 的目录，要求如下：

- 从 http://classroom.example.com/materials/private.html 下载一个文件副本到这个目录，并且重命名为 index.html，不要对这个文件的内容做任何修改。
- 从 server0 上，任何人都可以浏览 secret 的内容，但是从其它系统不能访问这个目录的内容



server0:

.. code-block:: bash

    [root@server0 ~]# mkdir -p /var/www/html/secret
    [root@server0 ~]# chcon -R -t httpd_sys_content_t /var/www/html/secret
    [root@server0 ~]# vim /etc/httpd//conf.d/httpd-vhosts.conf
    <Directory "/var/www/html/secret">
        AllowOverride None
        Require all denied
        Require local granted
    </Directory>
    [root@server0 ~]# systemctl restart httpd.service
    [root@server0 ~]# cd /var/www/html/secret/
    [root@server0 secret]# wget -O index.html http://classroom.example.com/materials/private.html
    [root@server0 secret]# cat index.html private test.
    [root@server0 ~]# systemctl restart httpd.service
    [root@server0 ~]# firefox



实现动态 WEB 内容
======================

试题概述：

在 system1 上配置提供动态 Web 内容，要求如下：

- 动态内容由名为 alt.groupX.example.com 的虚拟主机提供
- 虚拟主机侦听在端口 8998
- 从 http://classroom.com/materials/webinfo.wsgi 下载一个脚本， 然后放在适当的位置，无论如何不要修改此文件的内容
- 客户端访问 http://webapp0.example.com:8998 可接收到动态生成的 Web 页
- 此 http://webapp0.example.com:8998/必须能被 groupX.example.com 域内的所有系统访问

.. code-block:: bash

    [root@server0 ~]# yum install -y mod_wsgi
    [root@server0 ~]# vim /etc/httpd/conf/httpd.conf
    Listen 8998
    [root@server0 ~]# mkdir -p /var/www/webapp
    [root@server0 ~]# chcon -R -t httpd_sys_content_t /var/www/webapp
    [root@server0 ~]# semanage port -a -t http_port_t -p tcp 8998
    [root@server0 ~]# cd /var/www/webapp/
    [root@server0 webapp]# wget -O webapp.wsgi http://rhgls.domain1.example.com/materials/webapp.wsgi
    [root@server0 webapp]# cat webapp.wsgi
    #!/usr/bin/env python
    import time
    def application (environ, start_response):
        response_body = 'UNIX EPOCH time is now: %s\n' % time.time()
        status = '200 OK'
        response_headers = [('Content-Type', 'text/plain'),
                            ('Content-Length', '1'),
                            ('Content-Length', str(len(response_body)))]
        start_response(status, response_headers)
        return [response_body]
    [root@server0 webapp]# cd
    [root@server0 ~]# vim /etc/httpd/conf.d/httpd-vhosts.conf
    <VirtualHost *:8998>
    ServerName webapp0.example.com
    WSGIScriptAlias / /var/www/webapp/webapp.wsgi
    </VirtualHost>
    [root@server0 ~]# systemctl restart httpd.service
    [root@server0 ~]# firewall-cmd --permanent --add-port=8998/tcp success
    [root@server0 ~]# firewall-cmd --reload success
    [root@server0 ~]# firewall-config

.. image:: ../../../images/rhce1.jpg


.. code-block:: bash


创建一个脚本试题概述：
==============================================

在 system1 上创建一个名为/root/foo.sh 的脚本，让其提供下列特性：

- 当运行/root/foo.sh redhat，输出为 fedora
- 当运行/root/foo.sh fedora，输出为 redhat
- 当没有任何参数或者参数不是 redhat 或者 fedora 时，其错误输出产生以下的信息：
    /root/foo.sh redhat|fedora


.. code-block:: bash

    cd /root
    vim foo.sh
    #!/bin/bash
    case $1 in
    redhat)
    echo ' fedora '
    ;;
    fedora)
    echo ' redhat '
    ;;
    *)
    echo '/root/script redhat|fedora '
    esac



创建一个添加用户的脚本试题概述：
==============================================

在 system1 上创建一个脚本，名为/root/batchusers，此脚本能实现为系统 system1 创建本地用户，并且这些用户的用户名来自一个包含用户名的文件，同时满足下列要求：

- 此脚本要求提供一个参数，此参数就是包含用户名列表的文件
- 如果没有提供参数，此脚本应该给出下面的提示信息	Usage: /root/batchusers
    <userfile> 然后退出并返回相应的值

- 如果提供一个不存在的文件名，此脚本应该给出下面的提示信息 Input file not found 然后退出并返回相应的值
- 创建的用户登陆 Shell 为/bin/false，此脚本不需要为用户设置密码
- 您可以从下面的 URL 获取用户名列表作为测试用： http://smtp0.example.com/materials/userlist

.. code-block:: bash
    :linenos:

    [root@server0 ~]# vim /root/batchusers
    #!/bin/bash
    if [ $# -eq 0 ];then
      echo 'Usage: /root/batchusers userfile'
    exit 1
    fi

    if [ ! -f $1 ];then
      echo 'Input file not found'
    exit 1

    fi

    for i in `cat $1`
    do
      useradd -s /bin/false $i
    done
    [root@server0 ~]# vim /root/userlist
    user1
    user2
    alvin
    poppy
    china



配置 iSCSI 服务端试题概述：
==============================================

配置 system1 提供 iSCSI 服务，磁盘名为 iqn.2016-02.com.example:server0，并符合下列要求：

- 服务端口为 3260
- 使用 iscsi_store 作其后端卷，其大小为 3GiB
- 此服务只能被 group0.example.com 访问

.. code-block:: sh
    :linenos:

    fdisk /dev/vdb   分区3G

    yum -y install targetcli
    targetcli
    /> ls
    /> backstores/block create iscsi_store /dev/vdb1
    /> iscsi/ create iqn.2016-02.com.example:server0
    /> /iscsi/iqn.2016-02.com.example:server0/tpg1/acls create iqn.2016-02.com.example:desktop0
    /> /iscsi/iqn.2016-02.com.example:server0/tpg1/luns create /backstores/block/iscsi_store
    /> /iscsi/iqn.2016-02.com.example:server0/tpg1/portals create 172.25.0.11
    /> saveconfig
    /> exit

    systemctl restart target
    systemctl enable target

    firewall-cmd --permanent --add-port=3260/tcp
    firewall-cmd --reload
    firewall-cmd --list-all


配置 iSCSI 客户端试题概述：
==============================================

配置 desktop0 使其能连接 system1 上提供的 iqn.2016-02.com.example:server0，并符合以下要求：

- iSCSI 设备在系统启动的期间自动加载
- 块设备 iSCSI 上包含一个大小为 2100MiB 的分区，并格式化为 ext4 文件系统,此分区挂载在/mnt/data 上，同时在系统启动的期间自动挂载

.. code-block:: bash


    yum -y install iscsi-initiator-utils
    vim /etc/iscsi/initiatorname.iscsi
    InitiatorName=iqn.2016-02.com.example:desktop0

    iscsiadm -m discovery -t st -p server0
    iscsiadm -m node -T iqn.2016-02.com.example:server0 -p 172.25.0.11 -l

    systemctl restart iscsi iscsid
    systemctl enable iscsi iscsid

    lsblk

    fdisk /dev/sda 分2100M

    mkfs.ext4 /dev/sda1
    mkdir /mnt/data
    blkid /dev/sda1
    vim /etc/fstab
    UUID="088fd0f5-554e-48b3-ab20-5dd060d8c7ee"  /mnt/data ext4 _netdev 0 0
    mount -a
    iscsiadm -m discovery -t st -p server0
    iscsiadm -m node -T iqn.2016-02.com.example:server0 -p 172.25.0.11  -o update -n node.startup -v automatic

    sync ; reboot -f

..

    方法2
    yum -y install iscsi*
    yum repolist
    yum -y install iscsi*
    vim /etc/iscsi/initiatorname.iscsi
    systemctl restart iscsid
    systemctl enable iscsid
    iscsiadm -m discovery -t st -p server0
    systemctl restart iscsi
    systemctl enable iscsi
    lsblk
    blkid /dev/sda1
    vim /etc/fstab
    mkdir /mnt/data
    mount -a
    df -h
    reboot


配置一个数据库试题概述：
==============================================

在 system1 上创建一个 MariaDB 数据库，名为 Contacts，并符合以下条件：

- 数据库应该包含来自数据库复制的内容，复制文件的 URL 为： http://smtp0.example.com/materials/users.sql
- 数据库只能被 localhost 访问
- 除了 root 用户，此数据库只能被用户 Raikon 查询，此用户密码为 redhat
- root 用户的密码为 redhat，同时不允许空密码登陆。

.. code-block:: sh

    yum -y install mariadb-server mariadb
    vim /etc/my.cnf
    skip-networking

    systemctl restart mariadb
    systemctl enable mariadb

    mysqladmin -u root -p password 'redhat'
    mysql -u root -p

    CREATE DATABASE Contacts;
    GRANT select ON Contacts.* to Raikon@localhost IDENTIFIED BY 'redhat';
    DELETE FROM mysql.user WHERE Password='';
    QUIT

    wget http://classroom/pub/materials/mariadb/mariadb-users.sql -O users.sql
    vim users.sql
    use Contacts;

    create table if not exists base (id INT PRIMARY KEY auto_increment NOT NULL, name VARCHAR(100), password VARCHAR (100));
    create table if not exists location (id INT PRIMARY KEY auto_increment NOT NULL, name VARCHAR(100), city VARCHAR (100));

    insert into base(name,password) values ('bobo','123');
    insert into base(name,password) values ('harry','456');
    insert into base(name,password) values ('natasha','789');
    insert into base(name,password) values ('Barbara','solicitous');
    insert into location(name,city )values ('bobo','beijing');
    insert into location(name,city )values ('harry','shanghai');
    insert into location(name,city )values ('natasha','tianjin');
    insert into location(name,city )values ('Barbara','Sunnyvale');


    mysql -u root -p Contacts < users.sql


数据库查询（填空） 试题概述：
==============================================

在系统 system1 上使用数据库 Contacts，并使用相应的 SQL 查询以回答下列问题：

- 密码是 solicitous 的人的名字？

- 有多少人的姓名是 Barbara 同时居住在 Sunnyvale？



没有数据库环境，可以先创建数据库表和数据。

.. code-block:: sql

    create database Contacts;
    use Contacts;
    create table if not exists base (id INT PRIMARY KEY auto_increment NOT NULL, name VARCHAR(100), password VARCHAR (100));
    create table if not exists location (id INT PRIMARY KEY auto_increment NOT NULL, name VARCHAR(100), city VARCHAR (100));
    insert into base(name,password) values ('bobo','123');
    insert into base(name,password) values ('harry','456');
    insert into base(name,password) values ('natasha','789');
    insert into base(name,password) values ('Barbara','solicitous');
    insert into location(name,city )values ('bobo','beijing');
    insert into location(name,city )values ('harry','shanghai');
    insert into location(name,city )values ('natasha','tianjin');
    insert into location(name,city )values ('Barbara','Sunnyvale');


查询

::

    SELECT name FROM base WHERE password='solicitous';

    SELECT count(*) FROM location WHERE name='Barbara' AND city='Sunnyvale';

