# catchpy-provision
ansible provisioning for catchpy backend service

# for local vagrant catchpy

you'll need:

- vagrant
    - install dns plugin landrush: `$> vagrant plugin install landrush`
- virtualbox
- ansible

## start vagrant instances

this vagrantfile will start 2 ubuntu xenial instances:

    - postgres.vm (10.4.4.4)
    - catchpy.vm (10.4.4.5)

    $> git clone https://github.com/nmaekawa/catchpy-provision.git
    $> cd catchpy-provision
    $> vagrant up

this will only start the boxes, so they don't have anything installed yet.
you can change the tld and assigned local ips in the `Vagrantfile`.

you can login into each box like below:

    $> vagrant ssh catchpy
    # or
    $> ssh vagrant@catchpy.vm -i ~/.vagrant.d/insecure_private_key
    ...
    $> vagrant ssh postgres
    # or
    $> ssh vagrant@postgres.vm -i ~/.vagrant.d/insecure_private_key



## provision the instances

the ansible playbook.yml will provision both instances; to run:

    $> cd catchpy-provision
    
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
- nginx will redirect requests via http to https
- nginx certificates are dummy!
- django admin user is 'dragonman:password'

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
   
2. service_environment.CATCHPY_SECRET_KEY
   this is the SECRET_KEY for django sessions, crypt signing, etc
   
4. service_environment.CATCHPY_COMPAT_MODE
   default is `false` and means json responses will be in *Catchpy
   WebAnnotation*. Set to `true` to get *AnnotatorJS* as default.
   
4. service_admin_user/service_admin_password
   this is the django admin ui superuser. The provisioning will create this
   user automatically (and as side effect, a consumer key-pair will be
   generated as well). Change to values that make sense to you.
   
5. ssl_crt/ssl_key
   these are bogus ssl certificates that were copied from some other place.
   you might want to generate your own.




# credits

- https://github.com/jcalazan/ansible-django-stack
- http://michal.karzynski.pl/blog/2013/06/09/django-nginx-gunicorn-virtualenv-supervisor/



