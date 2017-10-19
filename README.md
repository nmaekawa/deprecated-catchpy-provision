# catchpy-provision
ansible provisioning for catchpy backend service

# for local vagrant catchpy

you'll need:

- catchpy git clone
- vagrant
    - install dns plugin landrush: `$> vagrant plugin install landrush`
- virtualbox
- ansible 2.4.0

## start vagrant instances

the vagrantfile in catchpy repo will start 2 ubuntu xenial instances:

    - postgres.vm
    - catchpy.vm

    $> git clone https://github.com/nmaekawa/catchpy-provision.git
    $> git clone https://github.com/nmaekawa/catchpy.git
    $> cd catchpy
    $> vagrant up

this will only start the boxes, so they don't have anything installed yet.
you can change the tld and assigned local ips in the `Vagrantfile`.

from the catchpy repo, you can login into each box like below:

    $> vagrant ssh catchpy
    # or
    $> ssh vagrant@catchpy.vm -i ~/.vagrant.d/insecure_private_key
    ...
    $> vagrant ssh postgres
    # or
    $> ssh vagrant@postgres.vm -i ~/.vagrant.d/insecure_private_key



## provision the instances

the ansible playbook.yml will provision both instances; to run:

    $> cd ../catchpy-provision
    
    # set vagrant insecure key in your env
    $> ssh-add ~/.vagrant.d/insecure_private_key
    $> ansible-playbook -i hosts/vagrant.ini playbook.yml
    
    # or specify it in the command line
    $> ansible-playbook -i hosts/vagrant.ini --private-key ~/.vagrant.d/insecure_private_key playbook.ym


the default configuration:

- postgres database `catchpy`, owned by user `catchpy` with password `catchpy`
- root dir for catchpy is `/opt/hx/catchpy`; in there you'll find the virtualenv,
  logs, catchpy repo clone, config/dotenv files
- catchpy django app will run with gunicorn; check
  `/opt/hx/catchpy/venvs/catchpy/bin/gunicorn_start`
- gunicorn is configured to talk to nginx via a socket at
  `/opt/hx/catchpy/venvs/run/gunicorn.sock`
- django admin user is 'dragonman:password'
- nginx for dev env uses HTTP (HTTPS will require certs that can be verified)

if all goes well, you should be able to check it out at
https://catchpy.vm/static/anno/index.html
and get the swagger ui for the annotation api.


## to play with this catchpy install

you can use the default api key-pair created for the django admin user; check
the table `consumer` in the django admin ui (or use `psql`, catchpy:catchpy).

the easiest way to generate an encoded token is to grab the key-pair from the
django admin user and paste it to http://jwt.io debugger.

first, paste the secret-key in the "verify signature" tab of jwt.io (the bottom
one, in blue).

then the payload must be something like:

    {
      "consumerKey": "the-consumer-key-from-django-admin-user",
      "userId": "some-dummy-user-id",
      "issuedAt": "YYYY-MM-DDTHH:mm:SS+00:00",
      "ttl": 6000
    }

the encoded token will show up in the left part of the screen.


# changing default configs

variables for the ansible provisioning are centralized at

    ansible-provision/vars/catchpy_vars.yml

currently, the provisioning works for vagrant instances only.

variables you might want to change:

1. service_db_*
   
   to mess up with database webapp user
   
2. service_environment.CATCHPY_DJANGO_SECRET_KEY
   
   this is the SECRET_KEY for django sessions, crypt signing, etc
   
3. service_admin_user/service_admin_password
   
   this is the django admin ui superuser. The provisioning will create this
   user automatically (and as side effect, a consumer key-pair will be
   generated as well). Change to values that make sense to you.
   
4. service_git_revision
   
   git branch, tag, or sha to be cloned in the catchpy instance.

# logs, restarting services

django app logs can be found at `/opt/hx/catchpy/logs/gunicorn_supervisor.log`

the django app is setup to use gunicorn and supervisor so if you need to restart
the webapp do:

    $> sudo supervisorctl restart catchpy


# credits

- https://github.com/jcalazan/ansible-django-stack
- http://michal.karzynski.pl/blog/2013/06/09/django-nginx-gunicorn-virtualenv-supervisor/



