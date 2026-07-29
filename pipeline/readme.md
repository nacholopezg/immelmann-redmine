# CI/CD Planifica

Este directorio contiene los recursos necesarios para la creación y configuración de las Pipelines de Openshift de construcción y despliegue de la aplicación *Planifica*.

## Entorno de construcción (ci)

- **Clúster**: ocpmgm
- **Namespace**: ci-cd

### Recursos

- `Pipeline`: `planifica-pipeline`
- `Tasks` (en el namespace `openshift-pipelines`): `git-clone` (default), `buildah` (default)
- `Secret`: `gitlab-credentials`, `quay-credentials`
- `PersistentVolumeClaim`: `planifica-pvc`

### Pipeline de construcción

La pipeline de construcción realiza las siguientes tareas:

- **Clonación del repositorio**: Usa la tarea `git-clone` para obtener el código desde GitLab. Clona únicamente los subdirectorios `src` y `build` del repositorio.
- **Construcción y publicación de la imagen**: Utiliza `buildah` para construir la imagen y subirla al registro de contenedores.

#### Parámetros

- `IMAGE_REPO`: Repositorio donde se almacenará la imagen.  
  **Valor por defecto**: `new-aesa-registry-quay-local-quay.apps.ocpmgm.aviacion.fomento.es`
  
- `IMAGE_NAME`: Ruta de la imagen dentro del repositorio.  
  **Valor por defecto**: `/aesa/planifica/planifica`
  
- `IMAGE_TAG`: Etiqueta (tag) de la imagen a construir.  
  
- `GIT_REPO`: URL del repositorio Git a clonar.  
  **Valor por defecto**: `https://gitlab.apps.ocpmgm.aviacion.fomento.es/ci-cd/aesa-planifica.git`
  
- `GIT_BRANCH`: Rama del repositorio Git a clonar.  
  **Valor por defecto**: `main`

#### Workspaces

- `planifica-pvc`: Almacena el código fuente clonado.
- `gitlab-credentials`: Contiene las credenciales para acceder al repositorio Git.
- `quay-credentials`: Contiene las credenciales para el registro de contenedores.


## Entorno de despliegue (cd)

- **Clústers**: ocpval, ocprec67, ocprec112, ocproc67, ocproc112
- **Namespace**: aesa-planifica

### Recursos:

- `Pipeline`: `planifica-pipeline`
- `Tasks` (en el namespace `openshift-pipelines`): `git-clone` (default), `deploy`
- `Secret`: `gitlab-credentials`
- `PersistentVolumeClaim`: `planifica-pipeline-pvc`

### Pipelines de desliegue

Las pipelines de despliegue realizan las siguientes tareas:

- **Clonación del repositorio**: Utilizan la tarea `git-clone` para obtener los ficheros de Kustomize. Clona únicamente el subdirectorio `deploy` del repositorio.
- **Despliegue de la aplicación**: Utilizan la tarea `deploy` para aplicar los cambios en el deployment de OpenShift y reiniciar la aplicación.

#### Parámetros

- `GIT_REPO`: URL del repositorio Git a clonar.  
  **Valor por defecto**: `https://gitlab.apps.ocpmgm.aviacion.fomento.es/ci-cd/aesa-planifica.git`
  
- `GIT_BRANCH`: Rama del repositorio Git a clonar.  
  **Valor por defecto**: `main`
  
- `OVERLAY_PATH`: Ruta al overlay de Kustomize dentro del repositorio.  
  **Valor por defecto**: `deploy/overlay/val`, `deploy/overlay/pre` o `deploy/overlay/pro` dependiendo del entorno de despliegue.
  
- `DEPLOYMENT_NAME`: Nombre del *Deployment* en OpenShift.  
  **Valor por defecto**: `planifica`

#### Workspaces:

- `planifica-pipeline-pvc`: Almacena los ficheros para el despliegue clonados.
- `gitlab-credentials`: Contiene las credenciales para acceder al repositorio Git.


## Notas

1. **Credenciales de los *Secrets* (`gitlab-credentials` y `quay-credentials`)**:  
   Los Secrets `gitlab-credentials` y `quay-credentials` que se incluyen dentro de los ficheros YAML de este repositorio no contienen credenciales reales sino que se han sustituido por `CHANGEME`. Deben actualizarse si van a ser utilizados.

2. **Tareas predeterminadas `git-clone` y `buildah`**:  
   Las tareas `git-clone` y `buildah` se incluyen de forma predeterminada en la instalación del operador de Pipelines de OpenShift en el `namespace` `openshift-pipelines` de todos los clústers.

3. **Tarea personalizada `deploy`**:  
   La tarea `deploy` se ha implementado y añadido al `namespace` `openshift-pipelines` para su uso en todas las pipelines dentro de cada clúster. Esta tarea debe estar creada en todos los clústers de los entornos de despliegue (validación, preproducción y producción).

4. **Replicación de recursos de despliegue en diferentes entornos**:  
    Los recursos para el despliegue de la aplicación deben replicarse en cada uno de los clústers de los entornos de validación, preproducción y producción. La única diferencia entre las pipelines de despliegue en los distintos entornos es el valor por defectos del parámetro `OVERLAY_PATH`. 

5. **Configuración del *pruner* de Tekton**:  
   Se ha habilitado un *pruner* en los clústers para eliminar automáticamente ejecuciones antiguas de las pipelines, conservando únicamente las 2 más recientes. Se ejecuta todos los días a medianoche (`0 0 * * *`), eliminando los `pipelinerun` junto con sus tareas (`taskrun`) y *pods* asociados. La configuración se ha aplicado desde:  
   `Administration > CustomResourceDefinitions > TektonConfig > Instances > config > YAML`.

   ```yaml
   pruner:
     disabled: false
     keep: 2
     prune-per-resource: true
     resources:
       - pipelinerun
     schedule: "0 0 * * *"
   ```

## Solución de errores

1. **Aumento de recursos para la tarea `git-clone`**:  
   Es posible que se presenten errores de checkout del código de las pipelines de construcción o despliegue si los recursos asignados a la tarea `git-clone` son insuficientes. Si se experimentan este tipo de errores, deben aumentarse los recursos asignados dentro de la tarea en el namespace `openshift-pipelines`. Ejemplo de configuración:
   ```yaml
   computeResources:
      limits:
        cpu: 500m
        memory: 512Mi
      requests:
        cpu: 500m
        memory: 512Mi
   ```

## Referencias

- [Documentación de OpenShift Container Platform](https://docs.redhat.com/en/documentation/openshift_container_platform/4.15)
- [Documentación de Tekton](https://tekton.dev/docs/getting-started/)
- [Requisitos para la configuración de los credenciales de GitLab para la tarea `git-clone` de Tekton](https://github.com/tektoncd/catalog/blob/main/task/git-clone/0.4/README.md)
- [Documentación del *pruner* de Tekton](https://docs.redhat.com/en/documentation/red_hat_openshift_pipelines/1.14/html/installing_and_configuring/customizing-configurations-in-the-tektonconfig-cr#op-automatic-pruning-taskrun-pipelinerun_customizing-configurations-in-the-tektonconfig-cr)

