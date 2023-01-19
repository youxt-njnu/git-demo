# python

> [官方文档](https://docs.python.org/3/)
>
> [本地链接](../python/python空间课件)
>
> [科学可视化的书](../python/scientific-visualization-book-master)

python的缺点

1. 运行速度慢
2. 加密难
3. 缩进规则
4. 多线程灾难

```python
# conda管理虚拟环境
conda create -n envname
conda activate envname
conda deactivate
conda env list

# conda管理安装包
conda list
conda install numpy
conda uninstall numpy
conda update numpy

# 帮助
import math
math.sin?
```

```python
# input, print, type, formalization
shot_id=1
print shot_id,type(shot_id)
print type(None)
radius=input("input the number for radius")
#字符串格式化，dictionary, .format(这里没给示例)
print "the radius is %f, and the area is %f sq cm." % (radius,radius*radius*2)
print "the radius is %(v1)f, and the area is %(v2)f sq cm." % {"v1":radius,"v2":radius*radius*2}

# slide
c='this is a new one'
c[0]
c[0:4]
c[-1:0:-1] #倒过来，不要第一个

# 反义字符
patha="c:\\desk"
pathb="c:/desk"
pathc=r"c:\desk"

# 列表list
data=[1,2,3,4]
del data
datacopy=data[:]
dataadd=data+datacopy
datamul=data*3
data.remove(1)
len(data)
sorted(data)
#function
data.append(), data.extend(),data.insert(),data.pop(), data.remove(), del data[1], data.reverse(), data.sort(), data.count()
for i,name in enumerate(roster):
    print(i,name)
# 列表推导表达式
lst=[i**2 for i in range(4)]
    
# 元组tuple
base=('a','b','c',3.4,1)
empt=tuple()

# 字典dict
jsdict={"A":1,
       "B":2}

x=["A",'B']
y=[1,2]
zip(x,y)
jsdict.get('C','not exist')
jsdict.keys()
jsdict.values()
for k,v in jsdict.items():
    print(k,v)
#字典推导表达式
jst={k:v for k,v in zip(x,y)}
    
# 集合set
se=set([1,1,2,5])# se={1,2,5}
se.union(senew) # function as se | senew
se.add()
se.remove()
se.intersection()# &
se.difference()# -
se.symmetric_difference()# ^
se.issubset(b)
se.issuperset(b)
se.isdisjoint(b)
```

```python
# random, if-else
import random
secret=random.randint(0.10)
guess=input("what is your guess")
if (guess!=secret)
	print "wrong"
else:
    print "yes"
```

```python
# while
x=89
while (x<100):
	print(x)
    x+1
```

```python
# for, range
for i in range(1,10,2):#i=1;i<10;i+=2; others:range(10),range(1,10)
	print(i)
```

```python
# def function
def add(a,b):
	c=a+b
	return c
polynomial= lambda x,y,z: 1+2*x+y*y+z*y

# 空函数
def func():
    pass
```

```python
# 数值型
abs(t)
int(t)
float(t)
round(t)
sum(T)
pow(t)
min(T)
max(T)
# 字符型
str(t)
len(s)
s.capitalize()
S.find(s)
s.islower()
s.isupper()
s.lower()
s.upper()
s.replace(old,new)
s.split(delimiter)
s.strip()

# math
import math
math.pi, math.e, math.sqrt(x), math.ceil(x), math.floor(x)

# time
# random
# os
import os
os.getcwd()
os.chdir("c:/")
os.listdir()
os.rename()
os.remove()
os.mkdir()
os.system()# 调用外部程序
os.path.exists()
os.path.isdir()
os.path.join()
os.path.split()
os.path.splitext()

f=open()
read(),readlines()
write(),writelines()
f.close()

# csv
# codecs

```

```python
class point(object):
    def __init__(self,x=0,y=0):
        self._x=x
        self._y=y
        
        
p1=point(x=12,y=34)
print(p1._x,p1._y)

#魔术方法
__int__
__del__
__str__
__repr__
# 运算符重载
# 访问控制和属性化
# 访问拦截器
# 属性装饰器
# 异常捕获
try:
    #todo
except a as A:
    #todo
except b asB:
    #todo
else:
    #todo
finally:
    
```

```python
# numpy
## ndarray对象
### 创建
a=np.array([1,2,3,4])
a=np.arange(0,1,0.1)
a=np.linspace(0,1,10,endpoint=False)
a=np.logspace(0,2,5)
a=np.empty((2,3),np.int)
a=np.zeros(4,np.int)
a=np.full(4,np.pi)
np.fromfunction()
c=np.array([i for i in range(16)],dtype=float)
### 属性
a=np.array([1,2,3],dtype=int) #float,complex
a.shape
b=a.reshape((4,4))
# 共用内存区，所以使用了=、切片、reshape的这种，不行，一个修改了另一个也会变
# 针对措施
# 使用序列下标，强制内存复制
c=a[np.arrange(1,3)]
# 切片赋值
a[3:5]=1,3
a[1::2]=5
# 使用列表/元组切片
a=[(1,3),(1,4)]#获取的就是a(1,1)和a(3,4)的地方
a.ndim
a.shape
a.size
a.dtype
a.itemsize
a.flags
a.real
a.imag

## ufunc对象
x=np.linspace(0,2*np.pi,11)
y=np.sin(x)
# 运算符重载
a=np.arange(1,5)
b=np.arange(0,4)
a+b, a*b, a-b, b/a
np.add(a,b), np.multiply(a,b), np.substract(a,b), np.divide(b,a)
=, equal()
!=, not_equl()
<=, not_equak()
>, greater()
>=, greater_equal()
# 自定义ufunc
def check_num(n,val):
    return val*n
b=np.array([check_num(i,1) for i in a])

ucheck_num=np.frompyfunc(check_num,2,1)
b=ucheck_num(a,1)
b=b.astype(np.int)

# 广播
y,x=np.ogrid[:5,:5]
y+x


# 函数库
from numpy import random as nr
nr.rand(4,3)
nr.poisson(2.0,(4,3))
randint, randn, choice, normal, uniform, poisson, shuffle
nr.choice(a,3)
np.sum(), average(), var(), mean(), std(), product()
np.sum(a,axis=1, keeydims=True)
min, max, ptp, argmin, mininum, maxinum, sort, argsort, percentile, median
unique(), bincount(), histogram()
vstack(), hstack(), column_stack(), split(),
```

```python
# matplotlib
import matplotlib.pyplot as plt
plt.ion()
plt.plot(x,y,label='$sin(x)$',color='r',linewidth=2)
plt.savefig("fig.png",dpi=300)
plt.subplot(221)
plt.sca(ax1)
plt.gca()

#line plot
fig,axe=plt.subplots()
axe.plot(x,y,'--b')
axe.set_xticks()
axe.set_yticks()
axe.minorticks_on()
axe.spines['right'].set_color('none')
axe.legend(loc='upper right', bbox_to_anchor=(1.1,1))
axe.annotate('content',xy=(1,23),arrowprops=dict(
facecolor='b',shrink=0.2),horizontalalighment='center')
axe.text(12,10,'content',bbox={'facecolor':'cyan','alpha':0.3,'pad':6})
plt.show()

# histogram
axe.hist(data,bins)
# scatter plot
axe.scatter(x,y)
# pie charts
axe.pie(sizes)
# bar charts
axe.bar(index,data_m)
axe.barh()
# table
axe.table(cellText=data,rowLabels=rows,colLabels=columns)
# 极坐标图
plt.rgrids(np.arange(0.5,2,0.5),angle=45)
plt.thetagrids([0,45])
plt.show()

# 3D
from mpl_toolkits.mplot3d improt Axes3D
fig=plt.figure()
axe=Axes3D(fig)
x=np.random.rand(N)
y=np.random.rand(N)
z=np.random.rand(N)
axe.scatter(x,y,z,marker='*')
axe.plot_surface(x,y,z,rstride=1,cstride=1,cmap=plt.cm.Blues_r,alpha=0.7)

# image
img=plt.imread('file.jpg')
plt.imshow(img)
import matplotlib.cm as cm
...
plt.imshow(z,extent=extent,origin="lower")

```

# jupyter notebook

1. [jupyter快速入门](..\dataProcessing)
2. [更改jupyter notebook工作目录](https://www.cnblogs.com/yang9165/p/12762481.html)
3. [机器学习新手必看：Jupyter Notebook入门指南](https://cloud.tencent.com/developer/news/225036)
4. [jupyter notebook三大附加功能，好用到飞起！](https://juejin.cn/post/6844903906959441933)
4. [使用Jupyter Notebook编写技术文档](https://www.cnblogs.com/noticeable/p/9010881.html)

# 其他的一些扩充

1. [python timeit模块的使用](https://blog.csdn.net/weixin_43790276/article/details/103848054)
2. [Timeit in Jupyter Notebook](https://linuxhint.com/timeit-jupyter-notebook/)
3. [安装PIL](https://blog.csdn.net/username666/article/details/113598726)
4. [安装opencv](https://blog.csdn.net/weixin_35684521/article/details/81953047)
5. 



# 相关库

shapely

ogr

cartopy

gdal

[opencvTutor](opencvTutor)

