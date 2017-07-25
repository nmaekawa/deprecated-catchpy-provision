# catchpy-provision
ansible provisioning for catchpy backend service

# for local vagrant catchpy

## you'll need

- vagrant
- virtualbox
- ansible

### start vagrant instances

this vagrantfile will start 2 ubuntu xenial instances, one for postgres with ip
10.3.3.4, other for the catchpy django app with ip 10.3.3.3

    $> git clone https://github.com/nmaekawa/catchpy-provision.git
    $> cd catchpy-provision
    $> vagrant up

you can login into each box like below:

    $> vagrant ssh catchpy
    ...
    $> vagrant ssh postgres

this will only start the boxes, so they don't have anything installed yet.


### provision the instances

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

if all goes well, you should be able to check it out at https://10.3.3.3/annos
and get a auth error!

    {"status": 401, "payload": "failed to find auth token in request header"}



based on
    - https://github.com/jcalazan/ansible-django-stack
    - http://michal.karzynski.pl/blog/2013/06/09/django-nginx-gunicorn-virtualenv-supervisor/



