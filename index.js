const counter = document.querySelector(".views");
        
        async function updateCounter() {
            try {
                // Use your actual API Gateway Invoke URL
                let response = await fetch('https://4ku97pvz16.execute-api.ap-southeast-2.amazonaws.com/dev/visitors');
                if (!response.ok) {
                    throw new Error(`HTTP error! Status: ${response.status}`);
                }
                let data = await response.json();
                counter.innerHTML = `${data.countOfViews}`;
            } catch (error) {
                console.error('Error fetching the view count:', error);
                counter.innerHTML = 'work in progress';
            }
        }

        updateCounter();