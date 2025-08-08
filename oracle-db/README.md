# Oracle XE on OL8
I needed to setup an Oracle database to test/play around with some new tools and thought I'd create a machine image instead.

**NOTE**: for Oracle Linux images, an additional field, `source_image_project_id` needs to be specified otherwise it's not in the default list that Packer searches and you'll get an error.


## Setting up Oracle
You need to configure your database first:
```
sudo /etc/init.d/oracle-xe-21c configure
```
You'll have to set a password and it will create an initial Pluggable DB (PDB) called `XEPDB1` that you can connect to.   


### Configuring the Listener
In `${ORACLE_HOME}/network/admin`, you need to add a `listener.ora` file and restart the Oracle DB (`sudo /etc/init.d/oracle-xe-21c restart`)

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
