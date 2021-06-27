# ci-cd

Set of scripts automating delivery and deployment of small projects.

- Simple config file for each project.
- Build multiple versions and deliver them to server from local machine with `delivery.sh`.
- Deploy any of delivered versions (easy updates and rollbacks) to production with `deploy.sh`.

> This works for me but... I don't do bash scripting and this solution is very naive. It will always tell you that it was success, and it will not warn you if something is wrong.

## Delivery

Delivery script to automate simple projects delivery to server from development machine.
It should run tests, package for production, and deliver build to server.
It will use ssh so you should have ssh access to server.

### Delivery configuration

Create 1 conf file per project. Use `template.conf` as template and fill in your project and server details.
Place your config in same conf folder so it is ignored by git as it will contain server details.

### Delivery usage

Run `./deliver.sh -c conf/myapp.com.conf -v v1.27.0` to deliver app configured in `conf/myapp.conf` to server.
It will be deliverd in a folder named `v1.27.0` to server. Those packages are later used by `deploy.sh`.

Both -c (path to conf file) and -v (version number) are required params.

## Deploy

Deployment script to automate deployments of different build versions to production. Deployment is done, by just
changing a symlink of folder that server is serving to specified version.

As builds are delivered to user folder, where server runned by www-data does not have access, the build is first copied to `/apps/appname`. Than it is linked to folder which server is serving, ex `/var/www/appname`. Doing rollback or deploying of any version is done by just running `deploy.sh` again with new or old version number.

## Deploy usage

Place `deploy.sh` on server.

Run `sudo ./deploy.sh -a myapp.com -v v1.27.0`

Both -a (app folder name) and -v (version number) are required params. App folder have to match -a, and it has to contains `builds` folder which contains build named by version like `appname/builds/v1.27.0`.

`sudo ./deploy.sh -a myapp.com -v v1.26.0` to rollback if current version was `v1.27.0`.

## License

`ci-cd` is released under the MIT license.