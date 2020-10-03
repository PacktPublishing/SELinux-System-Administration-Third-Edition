# Upload the test.cil file
/usr/share/selinux/custom/test.cil:
  file.managed:
    - source: salt://packt_selinux/test.cil
    - mode: 644
    - user: root
    - group: root
    - makedirs: True

# (Re)set the context of the resource
{%- set path = '/usr/share/selinux/custom/test.cil' %}
{%- set context = 'system_u:object_r:usr_t:s0' %}
set {{ path }} context:
  cmd.run:
    - name: chcon {{ context }} {{ path }}
    - unless: test $(stat -c %C {{ path }}) == {{ context }}

# Load the test.cil file
load test.cil:
  selinux.module:
    - name: test
    - source: /usr/share/selinux/custom/test.cil
    - install: True
    - unless: "semodule -l | grep -q ^test$"

# SELinux booleans
httpd_builtin_scripting:
  selinux.boolean:
    - value: True

# SELinux file context
"/srv/web(/.*)?":
  selinux.fcontext_policy_present:
    - sel_type: httpd_sys_content_t

# Ensure system is in enforcing mode
enforcing:
  selinux.mode

tcp/10122:
  selinux.port_policy_present:
    - sel_type: ssh_port_t

# Using cmd.run example
taylor_is_unconfined_user:
  cmd.run:
    - name: "semanage login -a -s unconfined_u taylor"
    - unless: "semanage login -l | grep -q '^taylor.*unconfined_u'"
