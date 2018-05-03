# GlobalVoices

Current build status:

`master`: PENDING

`develop`: [![CircleCI](https://circleci.com/gh/globalvoices/NewsFrames/tree/develop.svg?style=svg&circle-token=17b3efbddd46c82f3b38527e358a404cc5cce0ae)](https://circleci.com/gh/globalvoices/NewsFrames/tree/develop)

## Requirements

* Ruby 2.4.1
* PostgreSQL >= 9.4
* Bundler (`gem install bundler`)
* Node
* Etherpad

## Etherpad setup

* `wget https://github.com/ether/etherpad-lite/archive/1.6.1.tar.gz`
* `tar -zxvf 1.6.1.tar.gz`
* `rm 1.6.1.tar.gz`
* `mv etherpad-lite-1.6.1 etherpad`
* `cd etherpad/src`
* `npm install`
* `cd ..`
* `npm install ep_fileupload ep_copy_paste_images ep_previewimages ep_embedded_hyperlinks ep_document_import_hook ep_import_documents_images ep_markdown ep_export_cp_html_image ep_font_size ep_desktop_notifications ep_special_characters ep_foot_note ep_automatic_logut`
* `cp -R etherpad_plugins/ep_gv_insert_image etherpad/node_modules/ep_gv_insert_image`
* `cd ..`
* `echo "test-api-key" > ./etherpad/APIKEY.txt`
* `cp config/etherpad.json.example ./etherpad/settings.json`
* customize `./etherpad/settings.json` as needed
  * Add your domain to enable the custom plugin `"ep_gv_insert_image": {"domains": ["http://localhost:3000"]}`

## BiasDetector setup:

* Make sure python 2.7.x is installed
* Run `pip install -r bias-detector/requirements.txt`
* Run `python -m nltk.downloader all`

If you face issue while installing libraries, you may have to run `pip` tool using sudo privileges.

To test bias detector, go to `bias-detector/bsd/bsdetector` and type `python newsframe.py "hello world"`. If it works, your bias detector installation is working fine.

## Rails setup

* `cp .env.example .env`
* customize `.env`
* `ETHERPAD_URL` should point to the root of the Etherpad server (no path)
* `ETHERPAD_API_KEY` should be the same as the contents of `./etherpad/APIKEY.txt`

* `bundle install`
* `bundle exec rake db:create`
* `bundle exec rake db:schema:load`
* `bundle exec rake db:seed`

## Running

* `./etherpad/bin/run.sh`
* `bundle exec rails server`

## Testing

* `bundle exec rake spec`

## Deployment

One-time server setup:

* create and customize environment as needed (edit `~/.rbenv/vars`)

Deploy application (staging):

* `bundle exec cap staging deploy`

Once the application code is deployed, you can control the processes (see `config/god.rb`) with:

* `bundle exec cap staging server:start`
* `bundle exec cap staging server:restart`
* `bundle exec cap staging server:stop`

We have continuous integration enabled using Circle CI. Builds are created, tests are run for every checkin in every branch. Staging build is deployed when `master` or `develop` is updated.

**Etherpad deployment:**

* Follow the "Etherpad setup" instructions above but generate a real, random API key
* Configure `settings.json` to use Postgres
* Patch the following issue in one of Etherpad's depencencies: https://github.com/ether/etherpad-lite/issues/3128 https://github.com/Pita/ueberDB/pull/93
  * `rm -rf ./etherpad/src/node_modules/ueberdb2/node_modules/pg`
  * edit `./etherpad/src/node_modules/ueberdb2/package.json` and bump the `pg` version to `6.1.5`
  * from `./etherpad/src`, run `npm install`
* Start Etherpad server with `./etherpad/bin/run.sh`

**Deploy application (production):**

Server is configured using ansible playbook. See ansible/README.md

Once server is configured, change nginx cache permissions as following. You would need sudo access to do it.

	chown -R www-data:www-data /var/cache/nginx

**Running (production):**

To control server from your local machine, type:

* `bundle exec cap production server:start`
* `bundle exec cap production server:restart`
* `bundle exec cap production server:stop`

To control server after ssh, preferred approach is to use `systemctl` if configured, but you can also use:

* `bundle exec god -c config/god.rb`
* `bundle exec god terminate`

To start etherpad, you have to ssh. Preferred approach is to use `systemctl` if configured, but you can also use:

`nohup ./etherpad/bin/run.sh &`

To stop etherpad, you have to ssh. Preferred approach is to use `systemctl` if configured, else, you have to find the process id and kill it.

**Autostart app (production)**

We use 2 systemd scripts to start app processes when machine is rebooted - `scripts/newsframes.service` and `scripts/etherpad.service`. These are not deployed using ansible and should be done manually in `/etc/systemd/system`. If the system does not support systemd, init.d scripts will have to be written specifically.

Once the scripts have been deployed, the following commands can be used to run the scripts on machine boot:

* `sudo systemctl enable newsframes.service`
* `sudo systemctl enable etherpad.service`

The following commands can be used to control these services:

* `sudo systemctl status newsframes.service`
* `sudo systemctl status etherpad.service`
* `sudo systemctl start newsframes.service`
* `sudo systemctl start etherpad.service`
* `sudo systemctl stop newsframes.service`
* `sudo systemctl stop etherpad.service`
* `sudo systemctl restart newsframes.service`
* `sudo systemctl restart etherpad.service`
* `sudo journalctl restart -u newsframes.service -f`
* `sudo journalctl restart -u etherpad.service -f`

## Notes

To create an admin, run (without <>)

* `bundle exec rake admin:invite_admin name=<name here> email=<email here>`

If an existing user is to be made admin, just use the email parameter.
