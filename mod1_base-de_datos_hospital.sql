CREATE TABLE doctors
(
    staff_id             NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY NOT NULL,
    doctor_name          VARCHAR(25)                                     NOT NULL,
    doctor_lastname      VARCHAR(25)                                     NOT NULL,
    doctor_date_of_birth DATE                                            NOT NULL,
    doctor_age           INTEGER
);

CREATE TABLE patients
(
    patient_id            NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY NOT NULL,
    patient_gender        CHAR(1)                                         NOT NULL,
    patient_date_of_birth DATE                                            NOT NULL,
    patient_name          VARCHAR(25)                                     NOT NULL,
    patient_lastname      VARCHAR(25)                                     NOT NULL,
    patient_height        INTEGER                                         NOT NULL,
    patient_weight        INTEGER                                         NOT NULL,
    patient_cellphone     VARCHAR(15)                                     NOT NULL
);

CREATE TABLE doctors_assigned_to_patients
(
    da_to_patients_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY NOT NULL,
    patient_id        INTEGER                                         NOT NULL,
    staff_id          INTEGER                                         NOT NULL,
    date_from         DATE                                            NOT NULL,
    date_to           DATE                                            NOT NULL,
    FOREIGN KEY (staff_id) REFERENCES doctors (staff_id),
    FOREIGN KEY (patient_id) REFERENCES patients (patient_id)
);

CREATE TABLE patient_records
(
    patient_record_id  NUMBER GENERATED ALWAYS AS IDENTITY NOT NULL,
    billable_item_code VARCHAR(10)                         NOT NULL,
    component_code     VARCHAR(10)                         NOT NULL,
    update_by_staff_id VARCHAR(10)                         NOT NULL,
    updated_date       DATE                                NOT NULL,
    admission_datetime DATE                                NOT NULL,
    medical_condition  VARCHAR(20)                         NOT NULL,
    patient_id         INTEGER                             NOT NULL,
    FOREIGN KEY (patient_id) REFERENCES patients (patient_id)
);

CREATE TABLE diagnoses
(
    diagnosis_id           NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY NOT NULL,
    patient_id             INTEGER                                         NOT NULL,
    diagnosis_by_doctor_id INTEGER                                         NOT NULL,
    diagnosis_details      VARCHAR(200)                                    NOT NULL,
    FOREIGN KEY (patient_id) REFERENCES patients (patient_id),
    FOREIGN KEY (diagnosis_by_doctor_id) REFERENCES doctors (staff_id)
);

CREATE TABLE ref_drug_categories
(
    drug_category_code        NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY NOT NULL,
    drug_category_description VARCHAR(200)                                    NOT NULL
);

CREATE TABLE drugs
(
    drug_id            NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY NOT NULL,
    drug_name          VARCHAR(20)                                     NOT NULL,
    drug_description   VARCHAR(20)                                     NOT NULL,
    drug_cost          INTEGER                                         NOT NULL,
    drug_cost_unit     VARCHAR(2)                                      NOT NULL,
    other_details      VARCHAR(50)                                     NOT NULL,
    drug_category_code INTEGER                                         NOT NULL,
    FOREIGN KEY (drug_category_code) REFERENCES ref_drug_categories (drug_category_code)
);

CREATE TABLE patient_drugs_treatments
(
    pd_treatments     NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY NOT NULL,
    date_administered DATE                                            NOT NULL,
    comments          VARCHAR(100)                                    NOT NULL,
    patient_id        INTEGER                                         NOT NULL,
    diagnosis_id      INTEGER                                         NOT NULL,
    drug_id           INTEGER                                         NOT NULL,
    FOREIGN KEY (patient_id) REFERENCES patients (patient_id),
    FOREIGN KEY (drug_id) REFERENCES drugs (drug_id),
    FOREIGN KEY (diagnosis_id) REFERENCES diagnoses (diagnosis_id)
);

CREATE TABLE wards
(
    ward_number      NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY NOT NULL,
    ward_name        VARCHAR(20)                                     NOT NULL,
    ward_location    VARCHAR(20)                                     NOT NULL,
    ward_description VARCHAR(100)                                    NOT NULL
);

CREATE TABLE beds
(
    bed_id       NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY NOT NULL,
    bed_number   INTEGER                                         NOT NULL,
    bed_location VARCHAR(20)                                     NOT NULL,
    ward_number  INTEGER                                         NOT NULL,
    FOREIGN KEY (ward_number) REFERENCES wards (ward_number)
);

CREATE TABLE patients_in_beds
(
    pb_id      NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY NOT NULL,
    date_from  DATE                                            NOT NULL,
    bed_id     INTEGER                                         NOT NULL,
    patient_id INTEGER                                         NOT NULL,
    date_to    DATE                                            NOT NULL,
    FOREIGN KEY (patient_id) REFERENCES patients (patient_id),
    FOREIGN KEY (bed_id) REFERENCES beds (bed_id)
);

-- doctors data
INSERT INTO doctors (doctor_name, doctor_lastname, doctor_date_of_birth, doctor_age)
VALUES ('Joel', 'Smith', to_date('1988-12-10', 'YYYY-MM-DD'), 33);
INSERT INTO doctors (doctor_name, doctor_lastname, doctor_date_of_birth, doctor_age)
VALUES ('Saul', 'Fuentes', to_date('1995-12-10', 'YYYY-MM-DD'), 25);
INSERT INTO doctors (doctor_name, doctor_lastname, doctor_date_of_birth, doctor_age)
VALUES ('Ana', 'Marga', to_date('1975-12-10', 'YYYY-MM-DD'), 38);

-- patients data
INSERT INTO patients (patient_gender, patient_date_of_birth, patient_name, patient_lastname, patient_height,
                      patient_weight, patient_cellphone)
VALUES ('m', to_date('1988-12-10', 'YYYY-MM-DD'), 'Carlos', 'Almada', 170, 63, '+591 76567575');
INSERT INTO patients (patient_gender, patient_date_of_birth, patient_name, patient_lastname, patient_height,
                      patient_weight, patient_cellphone)
VALUES ('f', to_date('1991-11-10', 'YYYY-MM-DD'), 'Ana', 'Soliz', 159, 55, '+51 45128526');
INSERT INTO patients (patient_gender, patient_date_of_birth, patient_name, patient_lastname, patient_height,
                      patient_weight, patient_cellphone)
VALUES ('m', to_date('2000-06-10', 'YYYY-MM-DD'), 'Carlos', 'Almada', 180, 75, '+52 765675754');