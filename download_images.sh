#!/bin/bash

# Create assets/images directory if it doesn't exist
mkdir -p assets/images

echo "Downloading images to assets/images/..."

# Helper function to download an image
download_image() {
    local url=$1
    local output=$2
    echo "Downloading $output from $url..."
    curl -L -o "assets/images/$output" "$url"
}

# --- ROOMS ---
download_image "https://images.unsplash.com/photo-1631049307264-da0ec9d70304" "room_101.jpg"
download_image "https://images.unsplash.com/photo-1560448204-e02f11c3d0e2" "room_102.jpg"
download_image "https://images.unsplash.com/photo-1618773928121-c32242e63f39" "room_103.jpg"
download_image "https://images.unsplash.com/photo-1598928506311-c55ded91a20c" "room_104.jpg"
download_image "https://images.unsplash.com/photo-1590490360182-c33d57733427" "room_201.jpg"
download_image "https://images.unsplash.com/photo-1584132967334-10e028bd69f7" "room_202.jpg"
download_image "https://images.unsplash.com/photo-1582719478250-c89cae4dc85b" "room_301.jpg"
download_image "https://images.unsplash.com/photo-1591088398332-8a7791972843" "room_302.jpg"

# Additional rooms from JSON
download_image "https://images.unsplash.com/photo-1554995207-c18c203602cb" "room_std_1.jpg"
download_image "https://images.unsplash.com/photo-1596394516093-501ba68a0ba6" "room_std_2.jpg"
download_image "https://images.unsplash.com/photo-1563911302283-d2bc129e7570" "room_std_3.jpg"
download_image "https://images.unsplash.com/photo-1618221118493-9cfa1a1c00da" "room_dlx_3.jpg"
download_image "https://images.unsplash.com/photo-1501117716987-19794d2ba74a" "room_vip_2.jpg"
download_image "https://images.unsplash.com/photo-1610641818989-c2051b5e2cfd" "room_vip_3.jpg"
download_image "https://images.unsplash.com/photo-1510798831971-661eb04b3739" "room_vip_4.jpg"

# --- SERVICES ---
download_image "https://images.unsplash.com/photo-1555244162-803834f70033" "service_buffet.jpg"
download_image "https://images.unsplash.com/photo-1544148103-0773bf10d330" "service_tea.jpg"
download_image "https://vinpearlresortvietnam.com/wp-content/uploads/Akoya-Spa-tai-Vinpearl-Phu-Quoc-resort.jpg" "service_spa.jpg"
download_image "https://images.unsplash.com/photo-1533473359331-0135ef1b58bf" "service_limousine.jpg"
download_image "https://lasinfoniavietnam.com/wp-content/uploads/2025/04/Fine-dining-1.jpg" "service_finedining.jpg"
download_image "https://vcdn1-vnexpress.vnecdn.net/2025/03/23/Image-474306479-ExtractWord-0-3207-7494-1742739576.png?w=680&h=0&q=100&dpr=2&fit=crop&s=6a0nlF28GLbrZOS6_1GEUw" "service_pool.jpg"
download_image "https://images.unsplash.com/photo-1554284126-aa88f22d8b74" "service_gym.jpg"
download_image "https://cdn.nhatrangbooking.com.vn/images/uploads/xe-dua-don-san-bay-top.jpg" "service_airport.jpg"
download_image "https://images.unsplash.com/photo-1583417319070-4a69db38a482" "service_tour.jpg"
download_image "https://www.miamihotel.vn/sites/default/files/bvs2021.jpg" "service_decor.jpg"

# --- OTHERS ---
download_image "https://images.unsplash.com/photo-1542314831-068cd1dbfeeb" "lobby.jpg"
download_image "https://images.unsplash.com/photo-1571896349842-33c89424de2d" "location.jpg"

echo "All downloads complete!"
