directory '/usr/share/selinux/custom' do
	owner 'root'
	group 'root'
	mode '0755'
	action :create
end

execute 'set_selinux_custom_context' do
	command '/usr/bin/chcon -t usr_t /usr/share/selinux/custom'
	action :nothing
	subscribes :run, 'directory[/usr/share/selinux/custom]', :immediately
end

cookbook_file '/usr/share/selinux/custom/test.cil' do
	source 'test.cil'
	owner 'root'
	group 'root'
	mode '0755'
	action :create
end

bash 'load_test_cil' do
	code '/usr/sbin/semodule -i /usr/share/selinux/custom/test.cil'
	not_if '/usr/sbin/semodule -l | grep -q ^test$'
	only_if { ::File.exists?('/usr/share/selinux/custom/test.cil') }
end

selinux_state "SELinux enforcing" do
	action :enforcing
end

selinux_policy_boolean 'httpd_builtin_scripting' do
	value false
end

selinux_policy_port '10122' do
	protocol 'tcp'
	secontext 'ssh_port_t'
end

selinux_policy_fcontext '/srv/web(/.*)?' do
	secontext 'httpd_sys_content_t'
end

selinux_policy_permissive 'zoneminder_t' do
end
