# Oracle XE on OL8
I needed to setup an Oracle database to test/play around with some new tools and thought I'd create a machine image instead.

**NOTE**: for Oracle Linux images, an additional field, `source_image_project_id` needs to be specified otherwise it's not in the default list that Packer searches and you'll get an error.


## Setting up Oracle
```
sudo /etc/init.d/oracle-xe-21c configure
```

- sample `listener.ora`:
```
LISTENER= 
  (ADDRESS_LIST=
    (ADDRESS=(PROTOCOL=tcp)(HOST=0.0.0.0)(PORT=1521))
  )

SID_LIST_LISTENER=
  (SID_LIST=
    (SID_DESC=
      (SID_NAME=XEPDB1)
      (ORACLE_HOME=/opt/oracle/product/21c/dbhomeXE)
    )
  )
```



## Connecting from Client
```
sqlplus USERNAME/PASSWORD@SERVER:PORT/DATABASE
```

```
sqlplus system/myPa55w0rd@12.34.56.89:1521/XEPDB1
```
