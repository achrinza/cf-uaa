load("@ytt:assert", "assert")

config_dir = "/etc/config"
secrets_dir = "/etc/secrets"

java_opts_list = [
  "-Djava.security.egd=file:/dev/./urandom",
  "-Dlogging.config={}/log4j2.properties".format(config_dir),
  "-Dlog4j.configurationFile={}/log4j2.properties".format(config_dir),
  "-DCLOUDFOUNDRY_CONFIG_PATH={}".format(config_dir),
  "-DSECRETS_DIR={}".format(secrets_dir),
  "-Dstatsd.enabled=true",
  "-Dservlet.session-store=database",
]

def java_opts(database_scheme):
  if not database_scheme in ['hsqldb' , 'mysql', 'postgresql']:
    assert.fail("database.scheme must be one of hsqldb, mysql, or postgresql")
  end

  ret = "-Dspring_profiles={}".format(database_scheme)
  for i in range(0, len(java_opts_list)):
    ret += " "
    ret += java_opts_list[i]
  end
  return ret
end
