# Order Utility (Salesforce SFDX)

## Overview

This repository contains a Salesforce Order / Product management utility built with:

- Apex **Domain / Selector / Unit-of-Work** patterns
- **REST APIs** for product search and order provisioning
- **Lightning Web Components (LWC)** for interactive order management on the Order record page

### Main use cases

- Search for products (including parent/child hierarchy) within a Price Book  
- Add multiple products with quantities to an Order  
- View and manage Order Items from the Order record page  
- Expose product search & order creation via REST APIs to external systems

---

## Repository structure

**Root**

- `sfdx-project.json` – SFDX project configuration (`AssignmentPOC`)
- `package.json` – Node tooling (ESLint, Prettier, LWC Jest)
- `.forceignore`, `.gitignore` – ignored files
- `.vscode/` – VS Code config
- `config/project-scratch-def.json` – scratch org definition
- `manifest/package.xml` – deployable metadata set  
- `searchProduct.yaml.rtf` – OpenAPI spec (RTF-wrapped) for the Product REST API
- `ordercreateapi.yaml.rtf` – OpenAPI spec (RTF-wrapped) for the Order & Order Product Creation

**Apex (business logic & APIs)** – `force-app/main/default/classes`

- **Core infrastructure**
  - `SObjectDomain.cls` / `SObjectDomainTest.cls` – base domain layer with lifecycle hooks
  - `SObjectSelector.cls` – base selector abstraction for SOQL queries
  - `ISObjectUnitOfWork.cls` – interface for unit-of-work pattern
  - `ApplicationDependencyContext.cls`
  - `ApplicationDependencyProvider.cls` / `ApplicationDependencyProviderTest.cls`
  - `ApplicationDependencyTestKit.cls` – test DI utilities

- **Domains**
  - `OrderDomain.cls` / `OrderDomainTest.cls` – rules for Order defaulting and validation
  - `OrderItemDomain.cls` / `OrderItemDomainTest.cls` – rules around Order Items
  - `ProductDomain.cls` / `ProductDomainTest.cls`

- **Selectors**
  - `OrderSelector.cls` / `OrderSelectorTest.cls`
  - `OrderItemSelector.cls` / `OrderItemSelectorTest.cls`
  - `ProductSelector.cls` / `ProductSelectorTest.cls`

- **Services & controllers**
  - `OrderManagementService.cls` / `OrderManagementServiceTest.cls` – orchestrates order workflows
  - `AvailableProductsController.cls` / `AvailableProductsControllerTest.cls`
  - `OrderProductsController.cls` / `OrderProductsControllerTest.cls`

- **REST resources**
  - `ProductRestResource.cls` / `ProductRestResourceTest.cls` – product search API (`@RestResource(urlMapping='/products/*')`)
  - `OrderRestResource.cls` / `OrderRestResourceTest.cls` – order provisioning API (`@RestResource(urlMapping='/orders/*')`)

**LWC (UI)** – `force-app/main/default/lwc`

- `availableProducts/`
  - `availableProducts.js` / `.html` / `.css`
  - Displays available products, allows selection + quantity entry, calls Apex to add products to an Order.

- `orderProducts/`
  - `orderProducts.js` / `.html` / `.css`
  - Shows and manages Order Items related to the current Order.

- `orderManagement/`
  - `orderManagement.js` / `.html`
  - Container component; coordinates activation status of the Order and interactions between `availableProducts` and `orderProducts`.

**Metadata (objects, layouts, pages)**

- `objects/Order/Order.object-meta.xml` – Order object configuration
- `objects/Product2/...` – Product2 customizations (e.g., `Parent_Product__c`)
- `layouts/` – updated layouts for Order and Product2
- `flexipages/Order_Record_Page.flexipage-meta.xml` – sample Order record Lightning page
- `profiles/Admin.profile-meta.xml` – profile adjustments for this setup

## Prerequisites

- **Salesforce DX (sfdx)** installed
- A Salesforce **scratch org**, **sandbox**, or **Developer org**
- **Node.js** and **npm** (for LWC tooling and Jest tests)

---

## Getting started

### 1. Clone the repo and install dependencies

```bash
git clone https://github.com/gauravpandeycsesf/Order-utility.git
cd Order-utility-main
npm install
