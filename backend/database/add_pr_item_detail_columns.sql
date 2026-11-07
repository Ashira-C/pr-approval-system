USE pr_approval;

-- เก็บ Name / Brand / Model / Detail ของแต่ละรายการแยกกัน เพื่อให้หน้าแก้ไข PR โหลดกลับมาได้ครบ
-- description ยังเก็บข้อความรวม (ใช้ใน PDF และ PR เก่าที่ไม่มีคอลัมน์เหล่านี้)
ALTER TABLE pr_item
    ADD COLUMN item_name VARCHAR(255) NULL AFTER description,
    ADD COLUMN brand     VARCHAR(255) NULL AFTER item_name,
    ADD COLUMN model     VARCHAR(255) NULL AFTER brand,
    ADD COLUMN detail    VARCHAR(255) NULL AFTER model;
