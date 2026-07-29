# aesa-planifica

## Getting started

La aplicación **planifica** monta un volumen NFS para el almacén de los ficheros adjuntos. Para poder montar volúmenes NFS en OpenShift hace falta utilizar el SecurityContext _hostmount-anyuid_, que tiene suficientes permisos para hacer este montaje.
La pipeline de despliegue crea una ServiceAccount nfs-mount y configura el deployment para utilizar dicha ServiceAccount, pero no tiene suficientes privilegios para asignar el SecurityContext necesario. Es por ello, que una vez ejecutada la pipeline es necesario ejecutar con un usuario con el rol cluster-admin el siguiente comando:

```
$ oc adm policy add-scc-to-user hostmount-anyuid -z nfs-mount -n aesa-planifica
clusterrole.rbac.authorization.k8s.io/system:openshift:scc:hostmount-anyuid added: "nfs-mount"
```

Este comando solo es necesario ejecutarlo tras el primer despliegue. Una vez ejecutado, la ServiceAccount mantiene su configuración aunque se produzcan nuevas ejecuciones de la pipeline