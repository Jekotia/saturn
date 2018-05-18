user { "pihole":
	ensure		=> "present",
	uid		=> "$_PIHOLE_UID",
	gid		=> "$_PIHOLE_GID",
	membership	=> "inclusive",
	system		=> "true",
}
group { "pihole":
	ensure		=> "present",
	gid		=> "$_PIHOLE_GID",
	system		=> "true",
}

file { "pihole data folder":
	path		=> "$_PIHOLE_DATA",
	ensure		=> "directory",
	group		=> "$_PIHOLE_GID",
	owner		=> "$_PIHOLE_UID",
	recurse		=> "true",
}
