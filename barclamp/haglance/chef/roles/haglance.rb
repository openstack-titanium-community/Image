name "haglance"
description "HaGlance Role"
run_list(
        "recipe[openstack-image::common]",
        "recipe[openstack-image::registry]", 
        "recipe[openstack-image::api]", 
        "recipe[openstack-image::identity_registration]" 
)
default_attributes()
override_attributes()
