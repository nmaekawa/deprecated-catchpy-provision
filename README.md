# catchpy-provision
ansible provisioning for catchpy backend service

# disclaimer
for demo purposes only! provided only to show how to setup a catchpy vagrant
installation and support to this repo is OUT-OF-SCOPE at this time.


# for local vagrant catchpy

you'll need:

- catchpy git clone
- vagrant
    - install dns plugin landrush: `$> vagrant plugin install landrush`
- virtualbox
- ansible 2.4.0

## start vagrant instance

the Vagrantfile will start a ubuntu xenial:

    - catchpy.vm

    $> git clone https://github.com/nmaekawa/catchpy-provision.git
    $> cd catchpy-provision
    $> vagrant up

this will only start the box, and it doesn't have anything installed yet.
you can change the tld and assigned local ips in the `Vagrantfile`.

login into box like below, so the ssh host key
fingerprint is stored in `~/.ssh/known_hosts`. This helps with ansible-playbook
when installing catchpy:

    $> ssh vagrant@catchpy.vm -i ~/.vagrant.d/insecure_private_key
    ...


## provision the instance

Run:

    # you do want a virtualenv
    $> cd catchpy-provision
    $> virtualenv venv
    $> source venv/bin/activate
    (venv) $> pip install ansible

    # install external ansible roles
    (venv) $> cd roles
    (venv) $> ansible-galaxy -r requirements.yml -p ./external

    # back to catchpy-provision root dir
    (venv) $> cd ..

    # set vagrant insecure key in your env
    (venv) $> ssh-add ~/.vagrant.d/insecure_private_key

    # playbook catchpy_allinone_play.yml will set the db and catchpy django
    (venv) $> ansible-playbook -i hosts/vagrant.ini catchpy_allinone_play.yml

if all goes well, you should be able to see the django-admin ui:

    http://catchpy.vm/admin

and check the catchpy api:

    http://catchpy.vm/static/anno/index.html

to create auth tokens, please refer to the catchpy repo readme:

    https://github.com/nmaekawa/catchpy


## the default configuration

running the provisioning like in the previous step, renders a default install:

- postgres database `catchpy`, owned by user `catchpy` with password `catchpy`
- root dir for catchpy is `/opt/hx/catchpy`; in there you'll find the virtualenv,
  logs, catchpy repo clone, config/dotenv files
- catchpy django app will run with gunicorn; check
  `/opt/hx/catchpy/venvs/catchpy/bin/gunicorn_start`
- django admin user is 'user:password'
- nginx for dev env uses HTTP


# changing default configs

as disclaimed, there is no support for provision and configuration. Proceed at
your own peril.

variables for the ansible provisioning are centralized at

    catchpy-provision/vars/catchpy_vars.yml


BUT, if you wish to just change django config stuff, defined it in the
environment. Check:

    catchpy-provision/catchpy_sample.env

and run the provision with these env vars:

    $> (source catchpy_sample.env; ansible-playbook -i hosts/vagrant.ini catchpy_allinone_play.yml)



# logs, restarting services

django app logs can be found at `/opt/hx/catchpy/log/catchpy.log`

the django app is setup to use gunicorn and supervisor so if you need to restart
the webapp do:

    $> sudo supervisorctl restart catchpy


# credits

- https://github.com/jcalazan/ansible-django-stack
- http://michal.karzynski.pl/blog/2013/06/09/django-nginx-gunicorn-virtualenv-supervisor/



