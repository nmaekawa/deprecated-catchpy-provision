# catchpy-provision
ansible provisioning for catchpy backend service

# disclaimer
for demo purposes only! provided to show how to setup a catchpy vagrant
installation and support to this repo is OUT-OF-SCOPE at this time.


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

from the catchpy repo, login into each box like below, so the ssh host key
fingerprint is stored in `~/.ssh/known_hosts`. This helps with ansible-playbook
when installing catchpy:

    $> ssh vagrant@catchpy.vm -i ~/.vagrant.d/insecure_private_key
    ...
    $> ssh vagrant@postgres.vm -i ~/.vagrant.d/insecure_private_key
    ...


## provision the instances

the ansible catchpy_install_play.yml will provision both instances; to run:

    $> cd ../catchpy-provision
    
    # set vagrant insecure key in your env
    $> ssh-add ~/.vagrant.d/insecure_private_key
    $> ansible-playbook -i hosts/vagrant.ini catchpy_install_play.yml
    
    # or specify it in the command line
    $> ansible-playbook -i hosts/vagrant.ini --private-key ~/.vagrant.d/insecure_private_key catchpy_install_play.ym


the default configuration:

- postgres database `catchpy`, owned by user `catchpy` with password `catchpy`
- root dir for catchpy is `/opt/hx/catchpy`; in there you'll find the virtualenv,
  logs, catchpy repo clone, config/dotenv files
- catchpy django app will run with gunicorn; check
  `/opt/hx/catchpy/venvs/catchpy/bin/gunicorn_start`
- gunicorn is configured to talk to nginx via a socket at
  `/opt/hx/catchpy/venvs/run/gunicorn.sock`
- django admin user is 'user:password'
- nginx for dev env uses HTTP

if all goes well, you should be able to check it out at
https://catchpy.vm/static/anno/index.html
and get the swagger ui for the annotation api.


## to play with this catchpy install

you will need an api consumer key-pair; the install playbook creates that and
you can check table `consumer` on the django admin ui at `http://catchpy.vm/admin`.

NOTE that the django admin ui is for queries only; it is NOT RECOMMENDED to
create/update records via django admin ui.

to generate an api token, check the django command `make_token`:

    $> cd catchpy
    
    # activate virtualenv, if using one
    $> source venv/bin/activate
    
    # it has a help!
    $> ./manage.py make_token --help
    ...
    # and will go somewhat like this, for a ttl of 10 min and user "mary_poppins"
    $> ./manage.py make_token --api_key "api_key" --secret_key "secret_key" --ttl 600 --user "mary_poppins"


# changing default configs

as disclaimed, there is no support for provision and configuration. Proceed at
your own peril.

variables for the ansible provisioning are centralized at

    catchpy-provision/vars/catchpy_vars.yml


BUT, if you wish to just change django config stuff, defined it in the
environment. Check:

    catchpy-provision/catchpy_sample.env


# logs, restarting services

django app logs can be found at `/opt/hx/catchpy/logs/gunicorn_supervisor.log`

the django app is setup to use gunicorn and supervisor so if you need to restart
the webapp do:

    $> sudo supervisorctl restart catchpy


# credits

- https://github.com/jcalazan/ansible-django-stack
- http://michal.karzynski.pl/blog/2013/06/09/django-nginx-gunicorn-virtualenv-supervisor/



