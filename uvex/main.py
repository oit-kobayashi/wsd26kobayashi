import cv2

img = cv2.imread('sample.jpg')
gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
edge = cv2.Canny(gray, 100, 200)
illust = cv2.stylization(img, sigma_s=60, sigma_r=0.07)

cv2.imshow('org', img)
cv2.imshow('gray', gray)
cv2.imshow('edge', edge)
cv2.imshow('illust', illust)
cv2.waitKey(0)
