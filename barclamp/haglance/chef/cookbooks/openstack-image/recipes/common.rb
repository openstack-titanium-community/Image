#
# Cookbook Name:: openstack-image
# Recipe:: common 
#
# Copyright 2013, AT&T Services, Inc.
# Copyright 2013, Craig Tracey <craigtracey@gmail.com>
# Copyright 2013, Opscode, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

class ::Chef::Recipe
  include ::Openstack
end
###############################################################
#               SET GLANCE ATTRIBUTES 
###############################################################
#Ip addresses must be assigned in recipes (not in attributes files to avoid conflicts between cookbooks)
# TODO: Change ip addresses to Vip
node.set['openstack']['endpoints']['image-registry']['host'] = node['ipaddress']
node.set['openstack']['endpoints']['image-api']['host'] = node['ipaddress']

###############################################################
#                PERCONA DATABASE DEPENDENCIES
###############################################################

::Chef::Log.info ">>>>>>> Retrieve Database Information <<<<<<<<< "
# TODO: Retrieve database virtual ip address and port 
# database_cluster = search(:node, "roles:percona")
# database = database_cluster[0]

dbs = search(:node, "roles:database-server")
db = dbs[0]
# node.set['openstack']['db']['image']['port'] = database["percona"]["server"]["port"]
node.set['openstack']['db']['image']['host'] = db['ipaddress']

::Chef::Log.info "** Retrieve Database Information End ** "
###############################################################
#                RABBITMQ DEPENDENCIES
###############################################################

::Chef::Log.info ">>>>>>> Retrieve RabbitMq Information <<<<<<<<< "
# TODO: Retrieve RabbitMQ attributes 
rabbitmq_cluster = search(:node, "roles:rabbitmq")
# rabbitmq = rabbitmq_cluster[0]

# node.set["openstack"]["image"]["rabbit"]["username"] = rabbitmq["rabbitmq"]["default_user"]
# node.set["openstack"]["image"]["rabbit"]["vhost"] = rabbitmq["rabbitmq"]["virtualhosts"]
# node.set["openstack"]["image"]["rabbit"]["port"] = rabbitmq["rabbitmq"]["port"]
# node.set["openstack"]["image"]["rabbit"]["host"] = ""

::Chef::Log.info "** Retrieve RabbitMQ Information End ** "

###############################################################
#                    GLANCE DATABASE OPERATIONS             
###############################################################
::Chef::Log.info "*** Glance Common Recipe ***"
::Chef::Log.info "** Glance DB Registration **"
root_user_use_databag = node['openstack']['db']['root_user_use_databag']

key_path = node["openstack"]["secret"]["key_path"]
user_key = node['openstack']['db']['root_user_key']

service_db_pwd_key = "glance"
db_passwords_bag = node["openstack"]["secret"]["db_passwords_data_bag"]

service_db_pwd  = secret db_passwords_bag, service_db_pwd_key 
::Chef::Log.info "Retrieve glance db password #{service_db_pwd}"

db_create_with_user "image",
                     node["openstack"]["image"]["db"]["username"],
                     service_db_pwd 

::Chef::Log.info "** Glance DB Registration End **"

###############################################################
#                KEYSTONE DEPENDENCIES 
###############################################################
::Chef::Log.info "** Retrieve Keystone Information **"
# TODO: Retrieve Keystone node (virtual ip and port as well as other attributes) 
keystones = search(:node, "roles:keystone-server")
keystone = keystones[0]

# Identity API Attributes
# node.set['openstack']['endpoints']['identity-api']['scheme'] = keystone['openstack']['endpoints']['identity-api']['scheme']
# node.set['openstack']['endpoints']['identity-api']['path'] = keystone['openstack']['endpoints']['identity-api']['path']
# node.set['openstack']['endpoints']['identity-api']['port'] = keystone['openstack']['endpoints']['identity-api']['port']
# Keystone virtual ip address should be retrieved from HaProxy
node.set['openstack']['endpoints']['identity-api']['host'] = keystone['ipaddress']

# Identity Admin Attributes
# node.set['openstack']['endpoints']['identity-admin']['scheme'] = keystone['openstack']['endpoints']['identity-admin']['scheme']
# node.set['openstack']['endpoints']['identity-admin']['path'] = keystone['openstack']['endpoints']['identity-admin']['path']
# node.set['openstack']['endpoints']['identity-admin']['port'] = keystone['openstack']['endpoints']['identity-admin']['port']
# Keystone virtual ip address should be retrieved from HaProxy
node.set['openstack']['endpoints']['identity-admin']['host'] = keystone['ipaddress']

::Chef::Log.info "** Retrieve Keystone Information End **"
