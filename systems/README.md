# NixOS System Configurations

This directory manages configurations for various NixOS machines in a centralized, organized manner.

## System Overview

- `omnix/` - Lenovo Ideapad Slim 5 (Personal Workstation)
- `cospi/` - Lenovo Ideapad 520 (Personal Machine) 
- `server/` - Base Server Configuration Template
- `blade/` - Asus Vivobook 16X (Development Laptop)
- `phoenix/` - KVM based VM on Oracle Cloud (Production Server)

## Configuration Structure

Each system mostly contains:

- `configuration.nix` - Main system configuration and settings
- `hardware-configuration.nix` - Hardware-specific setup and drivers
- Additional module configurations for system-specific customizations

## Deploying a New System

Follow these steps to add a new NixOS configuration:

1. Create a new system directory with a meaningful name
2. Use an existing system as a template for the basic structure
3. Customize the configuration files for your specific needs:
   - Update hardware configuration
   - Add required modules
   - Configure system-specific settings
4. Register the new system in `flake.nix`