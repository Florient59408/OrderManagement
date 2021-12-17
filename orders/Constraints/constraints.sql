Prompt********************************ADDING CONSTRAINTS *******************************

CREATE UNIQUE INDEX region_id_pk
ON regions (region_id);

ALTER TABLE regions
ADD ( 	
		CONSTRAINT region_id_pk
        PRIMARY KEY(region_id)
    );


CREATE UNIQUE INDEX name_pk
ON city (name);
   
ALTER TABLE city
ADD ( 
		CONSTRAINT name_pk 
		PRIMARY KEY(name),
		CONSTRAINT region_id_cit_fk
		FOREIGN KEY (region_id)
		REFERENCES regions(region_id)
	);

CREATE UNIQUE INDEX location_id_pk
ON locations(latitude, longitude);

ALTER TABLE locations
ADD(
    CONSTRAINT location_pk
    PRIMARY KEY (latitude, longitude),
    CONSTRAINT city_name_lcation_fk
    FOREIGN KEY (city_name) REFERENCES city(name)
);


CREATE UNIQUE INDEX user_id_pk 
ON users(user_id);

ALTER TABLE users 
ADD(
		CONSTRAINT user_pk
        PRIMARY KEY (user_id),
		CONSTRAINT type_user_chk CHECK(type IN ('client','employee'))
   );


CREATE UNIQUE INDEX employee_id_pk
ON employees (employee_id);

ALTER TABLE employees
ADD(
	CONSTRAINT employee_id_pk
	PRIMARY KEY (employee_id),
	CONSTRAINT user_id_emp_fk
	FOREIGN KEY (user_id) REFERENCES users(user_id)
);


CREATE UNIQUE INDEX client_id_pk
ON clients (client_id);

ALTER TABLE clients
ADD(
		CONSTRAINT client_id_pk
		PRIMARY KEY (client_id)  
   );


CREATE UNIQUE INDEX address_id_pk
ON address (address_id);
   
ALTER TABLE address
ADD ( 	
		CONSTRAINT address_id_pk
		PRIMARY KEY(address_id),
		CONSTRAINT location_add_fk
		FOREIGN KEY (latitude, longitude)
		REFERENCES locations(latitude, longitude),
		CONSTRAINT client_id_add_fk
		FOREIGN KEY (client_id)
		REFERENCES clients(client_id)
	);  


CREATE UNIQUE INDEX store_id_pk
ON stores (store_id);

ALTER TABLE stores
ADD ( 
		CONSTRAINT store_id_pk
       	PRIMARY KEY (store_id),
      	CONSTRAINT store_address_sto_fk
		FOREIGN KEY (store_address)
		REFERENCES address(address_id)          
    );

CREATE UNIQUE INDEX warehouse_id_pk
ON warehouses(warehouse_id);

ALTER TABLE warehouses
ADD(
    CONSTRAINT warehouse_id_pk
    PRIMARY KEY (warehouse_id),
    CONSTRAINT location_war_fk
    FOREIGN KEY (latitude, longitude) REFERENCES locations(latitude, longitude)
);


CREATE UNIQUE INDEX group_id_pk
ON article_group (group_id);

ALTER TABLE article_group 
ADD
(
	CONSTRAINT group_id_pk 
	PRIMARY KEY (group_id)
);


CREATE UNIQUE INDEX class_id_shi_cl_pk
ON shipping_class(class);

ALTER TABLE shipping_class
ADD(
	CONSTRAINT class_id_shi_cla_pk
	PRIMARY KEY (class)
);


CREATE UNIQUE INDEX article_id_art_pk
ON articles(article_id);

ALTER TABLE articles
ADD(
    CONSTRAINT article_id_art_pk
    PRIMARY KEY (article_id),
	CONSTRAINT group_id_art_fk
    FOREIGN KEY (group_id) REFERENCES article_group(group_id),
    CONSTRAINT class_art_fk
    FOREIGN KEY (class) REFERENCES shipping_class(class)
);


CREATE UNIQUE INDEX warehouse_art_pk
ON warehouse_article(article_id, warehouse_id);

ALTER TABLE warehouse_article
ADD(
    CONSTRAINT warehouse_art_pk
    PRIMARY KEY (article_id, warehouse_id),
    CONSTRAINT article_id_war_art_fk
    FOREIGN KEY (article_id) REFERENCES articles(article_id),
    CONSTRAINT warehouse_id_war_art_fk
    FOREIGN KEY (warehouse_id) REFERENCES warehouses(warehouse_id)
);


CREATE UNIQUE INDEX serice_id_pk
ON Services(service_id);

ALTER TABLE Services
ADD
(
    CONSTRAINT serice_id_pk
    PRIMARY KEY (service_id),
	CONSTRAINT type_services_chk CHECK(type IN ('percentage','fixed'))
);


CREATE UNIQUE INDEX article_service_pk
ON article_service(article_id, service_id);

ALTER TABLE article_service
ADD(
    CONSTRAINT article_service_pk
    PRIMARY KEY (article_id, service_id),
    CONSTRAINT article_id_art_ser_fk
    FOREIGN KEY (article_id) REFERENCES articles(article_id),
    CONSTRAINT service_id_art_ser_fk
    FOREIGN KEY (service_id) REFERENCES services(service_id)
);



ALTER TABLE list_price
ADD (
        CONSTRAINT lp_art_fk
        FOREIGN KEY (article_id)
        REFERENCES articles(article_id),
        CONSTRAINT lp_clt_fk
        FOREIGN KEY (client_id)
        REFERENCES clients(client_id)          
    );


CREATE UNIQUE INDEX installation_id_pk 
ON installations( installation_id);

ALTER TABLE installations 
ADD(
        CONSTRAINT installation_id_pk
        PRIMARY KEY (installation_id),
        CONSTRAINT inst_ser_fK    
        FOREIGN KEY (service_id)
        REFERENCES services(service_id)
   );


CREATE UNIQUE INDEX warranty_type_id_pk
ON warranties (warranty_id);

ALTER TABLE warranties
ADD(
        CONSTRAINT warranty_type_id_pk
        PRIMARY KEY (warranty_id),
        CONSTRAINT war_ser_fK    
        FOREIGN KEY (service_id)
        REFERENCES services (service_id)
   );


CREATE UNIQUE INDEX voucher_pk
ON vouchers (voucher_id);

ALTER TABLE vouchers 
ADD(
	CONSTRAINT voucher_pk
	PRIMARY key (voucher_id),
	CONSTRAINT  type_voucher_chk CHECK(type IN ('percentage', 'fixed'))
);

ALTER TABLE orders
ADD(
	CONSTRAINT order_number_pk
	PRIMARY KEY (order_number),
	CONSTRAINT billing_address_ord_fk
	FOREIGN KEY(billing_address) REFERENCES address(address_id),
	CONSTRAINT voucher_id_ord_fk
	FOREIGN KEY(voucher_id) REFERENCES Vouchers(voucher_id),
	CONSTRAINT creation_user_ord_fk
	FOREIGN KEY(creation_user) REFERENCES users(user_id),
	CONSTRAINT edition_user_ord_fk
	FOREIGN KEY(edition_user) REFERENCES users(user_id),
	CONSTRAINT store_id_ord_fk
	FOREIGN KEY(store_id) REFERENCES stores(store_id)
);


CREATE UNIQUE INDEX oi_pk
ON order_item (order_number, article_id, item_id);

ALTER TABLE order_item
ADD( 
		CONSTRAINT oi_pk
		PRIMARY key (order_number, article_id, item_id),
		CONSTRAINT order_number_oi_fk
		foreign key (order_number)
		REFERENCES orders(order_number),
		CONSTRAINT article_id_oi_fk
		foreign key (article_id)
		REFERENCES articles(article_id),
		CONSTRAINT service_id_oi_fk 
		FOREIGN KEY (service_id) REFERENCES services(service_id)
);


CREATE UNIQUE INDEX grp_voucher_PK
on group_voucher(group_id,voucher_id,start_date);

ALTER TABLE group_voucher
ADD( 
	CONSTRAINT grp_voucher_pk
	PRIMARY KEY (group_id,voucher_id,start_date),
	CONSTRAINT group_id_gv_fk
	FOREIGN KEY (group_id)
	REFERENCES article_group(group_id),
	CONSTRAINT voucher_id_gv_fk
	FOREIGN KEY (voucher_id)
	REFERENCES vouchers(voucher_id)
);



CREATE UNIQUE INDEX package_id_pk
ON packages(package_id);

ALTER TABLE packages
ADD ( 
		CONSTRAINT package_id_pk 
		PRIMARY KEY (package_id),
		CONSTRAINT pac_order_number_fk
		FOREIGN KEY (order_number)
		REFERENCES orders (order_number),
		CONSTRAINT pac_deli_add_fk 
		FOREIGN KEY (delivery_address)
		REFERENCES address(address_id),
		CONSTRAINT delivery_mode_pac_chk CHECK(delivery_mode IN ('home', 'agency')),
		CONSTRAINT statute_pac_chk CHECK(statute IN ('Delivred', 'not yet', 'Stopped'))
);



CREATE UNIQUE INDEX pi_pk
ON package_item(order_number, article_id, item_id, package_id);

ALTER TABLE package_item
ADD( 
	CONSTRAINT pi_pk 
	PRIMARY KEY (order_number, article_id, item_id, package_id),
	CONSTRAINT oi_pi_fK
	FOREIGN KEY (order_number, article_id, item_id) REFERENCES order_item(order_number, article_id, item_id),
	CONSTRAINT package_id_pac_ite_fk
	FOREIGN KEY (package_id) REFERENCES packages(package_id)
);

CREATE UNIQUE  INDEX sound_purchase_id_pk
ON Sound_purchase(sound_purchase_id);

ALTER TABLE Sound_purchase
ADD(
	CONSTRAINT sound_purchase_id_pk
	PRIMARY KEY(sound_purchase_id),
	CONSTRAINT group_sp_fk
	FOREIGN KEY (group_id) REFERENCES article_group(group_id)
);

CREATE UNIQUE INDEX sp_client_id_pk
ON Sound_purchase_client(sound_purchase_id, client_id);

ALTER TABLE Sound_purchase_client
ADD(
	CONSTRAINT sp_client_pk
	PRIMARY KEY(sound_purchase_id, client_id),
	CONSTRAINT sp_client_sp_fk
	FOREIGN KEY (sound_purchase_id) REFERENCES Sound_purchase(sound_purchase_id),
	CONSTRAINT sp_client_client_fk
	FOREIGN KEY (client_id) REFERENCES clients(client_id)
);

COMMIT;