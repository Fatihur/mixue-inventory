# Skema Database

## Tabel: users

| Field | Type | Length | Extra | Null |
|-------|------|--------|-------|------|
| uid | VARCHAR | 50 | PRIMARY KEY | NOT NULL |
| nama | VARCHAR | 100 | | NOT NULL |
| email | VARCHAR | 100 | | NOT NULL |
| role | VARCHAR | 20 | | NOT NULL |
| status | VARCHAR | 20 | | NOT NULL |
| dibuat_pada | TIMESTAMP | | | NOT NULL |
| diubah_pada | TIMESTAMP | | | NOT NULL |

## Tabel: barang

| Field | Type | Length | Extra | Null |
|-------|------|--------|-------|------|
| id | VARCHAR | 50 | PRIMARY KEY | NOT NULL |
| nama | VARCHAR | 100 | | NOT NULL |
| barcode | VARCHAR | 100 | | NOT NULL |
| kategori | VARCHAR | 50 | | NOT NULL |
| satuan | VARCHAR | 20 | | NOT NULL |
| stok | INT | | | NOT NULL |
| stok_minimal | INT | | | NOT NULL |
| pcs_per_box | INT | | | NOT NULL |
| harga | DOUBLE | | | NOT NULL |
| deskripsi | TEXT | | | NULL |
| dibuat_pada | TIMESTAMP | | | NOT NULL |
| diubah_pada | TIMESTAMP | | | NOT NULL |

## Tabel: barang_masuk

| Field | Type | Length | Extra | Null |
|-------|------|--------|-------|------|
| id | VARCHAR | 50 | PRIMARY KEY | NOT NULL |
| barang_id | VARCHAR | 50 | FOREIGN KEY | NOT NULL |
| nama_barang | VARCHAR | 100 | | NOT NULL |
| jumlah | INT | | | NOT NULL |
| keterangan | TEXT | | | NULL |
| user_id | VARCHAR | 50 | FOREIGN KEY | NOT NULL |
| nama_user | VARCHAR | 100 | | NOT NULL |
| tanggal | TIMESTAMP | | | NOT NULL |

## Tabel: barang_terpakai

| Field | Type | Length | Extra | Null |
|-------|------|--------|-------|------|
| id | VARCHAR | 50 | PRIMARY KEY | NOT NULL |
| barang_id | VARCHAR | 50 | FOREIGN KEY | NOT NULL |
| nama_barang | VARCHAR | 100 | | NOT NULL |
| jumlah | INT | | | NOT NULL |
| keterangan | TEXT | | | NULL |
| user_id | VARCHAR | 50 | FOREIGN KEY | NOT NULL |
| nama_user | VARCHAR | 100 | | NOT NULL |
| tanggal | TIMESTAMP | | | NOT NULL |

## Tabel: barang_expired

| Field | Type | Length | Extra | Null |
|-------|------|--------|-------|------|
| id | VARCHAR | 50 | PRIMARY KEY | NOT NULL |
| barang_id | VARCHAR | 50 | FOREIGN KEY | NOT NULL |
| nama_barang | VARCHAR | 100 | | NOT NULL |
| jumlah | INT | | | NOT NULL |
| keterangan | TEXT | | | NULL |
| user_id | VARCHAR | 50 | FOREIGN KEY | NOT NULL |
| nama_user | VARCHAR | 100 | | NOT NULL |
| tanggal_expired | TIMESTAMP | | | NOT NULL |
| tanggal_input | TIMESTAMP | | | NOT NULL |

## Tabel: orders

| Field | Type | Length | Extra | Null |
|-------|------|--------|-------|------|
| id | VARCHAR | 50 | PRIMARY KEY | NOT NULL |
| nomor_order | VARCHAR | 50 | | NOT NULL |
| items | ARRAY | | | NOT NULL |
| total_harga | DOUBLE | | | NOT NULL |
| status | VARCHAR | 20 | | NOT NULL |
| keterangan | TEXT | | | NULL |
| user_id | VARCHAR | 50 | FOREIGN KEY | NOT NULL |
| nama_user | VARCHAR | 100 | | NOT NULL |
| tanggal | TIMESTAMP | | | NOT NULL |

## Tabel: order_items (embedded dalam orders)

| Field | Type | Length | Extra | Null |
|-------|------|--------|-------|------|
| barang_id | VARCHAR | 50 | FOREIGN KEY | NOT NULL |
| nama_barang | VARCHAR | 100 | | NOT NULL |
| jumlah | INT | | | NOT NULL |
| harga | DOUBLE | | | NOT NULL |
| subtotal | DOUBLE | | | NOT NULL |

## Tabel: refunds

| Field | Type | Length | Extra | Null |
|-------|------|--------|-------|------|
| id | VARCHAR | 50 | PRIMARY KEY | NOT NULL |
| order_id | VARCHAR | 50 | FOREIGN KEY | NOT NULL |
| nomor_order | VARCHAR | 50 | | NOT NULL |
| alasan | TEXT | | | NOT NULL |
| jumlah_refund | DOUBLE | | | NOT NULL |
| status | VARCHAR | 20 | | NOT NULL |
| user_id | VARCHAR | 50 | FOREIGN KEY | NOT NULL |
| nama_user | VARCHAR | 100 | | NOT NULL |
| tanggal | TIMESTAMP | | | NOT NULL |
