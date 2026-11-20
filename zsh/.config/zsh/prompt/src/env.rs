use std::env;

pub struct EnvVars {
    pub user_name: String,
    pub home: String,
    pub pwd: String,
    pub shlvl: String,
    pub running_inside_container: String,
}

impl EnvVars {
    pub fn load() -> Self {
        let pwd = env::var("PWD").unwrap_or_else(|_| {
            env::current_dir()
                .map(|p| p.to_string_lossy().into_owned())
                .unwrap_or_else(|_| " ".to_string())
        });

        Self {
            user_name: env::var("USER").unwrap_or_else(|_| " ".to_string()),
            home: env::var("HOME").unwrap_or_else(|_| " ".to_string()),
            pwd,
            shlvl: env::var("SHLVL").unwrap_or_else(|_| " ".to_string()),
            running_inside_container: env::var("RUNNING_INSIDE_CONTAINER").unwrap_or_default(),
        }
    }
}
