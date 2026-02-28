use std::collections::HashMap;
use std::process::{Child, Command};

pub struct ServiceConfig {
    pub name: String,
    pub command: String,
    pub args: Vec<String>,
    pub port: Option<u16>,
}

pub struct ServiceInstance {
    pub config: ServiceConfig,
    pub process: Option<Child>,
}

pub struct ServiceRegistry {
    services: HashMap<String, ServiceInstance>,
}

impl ServiceRegistry {
    pub fn new() -> Self {
        Self {
            services: HashMap::new(),
        }
    }

    pub fn register(&mut self, config: ServiceConfig) {
        self.services.insert(
            config.name.clone(),
            ServiceInstance {
                config,
                process: None,
            },
        );
    }

    pub fn start(&mut self, name: &str) -> Result<(), String> {
        let service = self.services.get_mut(name)
            .ok_or("Service not found")?;

        if service.process.is_some() {
            return Err("Service already running".into());
        }

        let mut cmd = Command::new(&service.config.command);
        cmd.args(&service.config.args);

        let child = cmd.spawn().map_err(|e| e.to_string())?;
        service.process = Some(child);

        Ok(())
    }

    pub fn stop(&mut self, name: &str) -> Result<(), String> {
        let service = self.services.get_mut(name)
            .ok_or("Service not found")?;

        if let Some(mut child) = service.process.take() {
            child.kill().map_err(|e| e.to_string())?;
        }

        Ok(())
    }

    pub fn status(&self, name: &str) -> Result<bool, String> {
        let service = self.services.get(name)
            .ok_or("Service not found")?;

        Ok(service.process.is_some())
    }
}
