# postgis

修改坐标系：

`Select UpdateGeometrySRID('dissertation23','NJLandUse2018','geom',32650);`

查看坐标系：

`Select ST_SRID(geom) from dissertation23."NJLandUse2018";`