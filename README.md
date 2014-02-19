## SV Portal

SV Portal is an approved solution to manage volunteers work for conferences. It includes registration for volunteers, creation of conferences and corresponding tasks. Volunteers can register for conferences and set preferences for tasks.

## Authors
- Jonathan Diehl <mailto:jonathan.diehl@rwth-aachen.de>
- Christopher Gretzki <mailto:chirstopher.gretzki@rwth-aachen.de>

Developed in part at Just Landed (http://www.justlanded.com) and the Media
Computing Group at RWTH Aachen University (http://hci.rwth-aachen.de)

## Requirements
- Rails (>= 2.3.5)
- gems: will_paginate RedCloth mysql ar_mailer

## Mail Delivery
Mails are queued in the database (emails table) for batch delivery using ar_mailer.
You have two options to initiate batch delivery:

Daemon:

    ar_sendmail -d --batch-size 50 --delay 300

Cron Job:

    */5 * * * * /usr/bin/ruby /usr/bin/ar_sendmail -o --batch-size 50 --delay 300 --chdir /path/to/svportal --environment production

## License
MOZILLA PUBLIC LICENSE
Version 1.1

The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in
compliance with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS"
basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
License for the specific language governing rights and limitations
under the License.
