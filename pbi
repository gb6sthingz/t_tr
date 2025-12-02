accounts
	create the following AD management accounts + spns (for the sqldev machine). For each env where PBI will be (now for dev)
		gateway account
		account for the SQL Server data source
proxy
	if the gateway must use a proxy, make sure it'll be allowed 
firewall
	outbound tcp 443 to various azure machines
	do you need to specify the destination in the firewall rule ?
		can you use fqdn or only ips in the firewall rules ?
		can you use the service tags ?
		can you specify wildcards ?
		if only ips, note that they change every month
azure relay
	do you use azure relay ? The gateway can create a default one or it can use your existing relay
recovery key
	during the installation, you'll need to specify the recovery key (like a password). Have prepared a strong one, ideally
compliance
	do you need to keep data in the same azure region as the pbi service ?
resources
	cpu - we might need to add at least 1 extra core
	ram - we might need more
	storage - we might need more
