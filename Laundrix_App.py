import mysql.connector
from decimal import Decimal
from getpass import getpass
def create_connection():
    return mysql.connector.connect(
        host="127.0.0.1",
        user="root",
        password="Cherries@164",
        database="laundramat2"
    )


def register_user():
    conn = create_connection()
    cursor = conn.cursor()
    username = input("Enter username: ")
    password = input("Enter password: ")
    email = input("Enter email: ")

    try:
        # Check if email already exists
        cursor.execute("SELECT * FROM registration WHERE email = %s", (email,))
        if cursor.fetchone():
            print("An account with this email already exists. Please log in.")
            return False

        # Insert new user into registration table
        cursor.execute("INSERT INTO registration (username, password, email) VALUES (%s, %s, %s)",
                       (username, password, email))
        conn.commit()
        print("Registration successful.")
        return True
    except mysql.connector.Error as err:
        print(f"Error: {err}")
    finally:
        conn.close()

def login_user(c):
    conn = create_connection()
    cursor = conn.cursor()

    # Prompt user for login credentials
    email = input("Enter email: ")
    password = input("Enter password: ")


    try:
        # Check if user with provided email and password exists
        cursor.execute("SELECT * FROM registration WHERE email = %s AND password = %s", (email, password))
        user = cursor.fetchone()

        if user:
            print("Login successful.")
            return user[0]  # Return user ID
        else:
            if c<2:
                print("Incorrect email or password. Please try again.")
                c=c+1
                login_user(c)
            else:
                print("3 login attempts failed , user blocked")
                exit()
    except mysql.connector.Error as err:
        print(f"Error: {err}")
    finally:
        conn.close()


# ... Other functions ...

def add_to_cart(user_id, game_id=None, game_account_id=None):
    conn = create_connection()
    cursor = conn.cursor()
    try:
        if game_id:  # If this is a new game
            cursor.execute("""
            INSERT INTO CART (UserID, GameID) VALUES (%s, %s)
            """, (user_id, game_id))
        elif game_account_id:  # If this is a used game
            cursor.execute("""
            INSERT INTO CART (UserID, OldGameID) VALUES (%s, %s)
            """, (user_id, game_account_id))
        else:
            print("No game specified to add to cart.")
            return

        conn.commit()
        print("Game added to cart successfully.")
    except mysql.connector.Error as err:
        print(f"Error: {err}")
    finally:
        if conn.is_connected():
            conn.close()




def view_services(user_id):
    conn = create_connection()
    cursor = conn.cursor()
    try:
        print("\nAvailable Services:")
        cursor.execute("""
        SELECT Name, Prices, Offers, Descriptions, Ratings
        FROM profile p
        JOIN vendor v ON p.VendorID = v.VendorID
        """)
        services = cursor.fetchall()
        for service in services:
            print(f"Name: {service[0]}\nPrices: {service[1]}\nOffers: {service[2]}\nDescription: {service[3]}\nRatings: {service[4]}\n")
    except mysql.connector.Error as err:
        print(f"Error: {err}")
    finally:
        if conn.is_connected():
            conn.close()

def view_orders():
    conn = create_connection()
    cursor = conn.cursor()
    try:
        print("\nAll Orders:")
        cursor.execute("""
        SELECT o.OrderID, c.Name AS CustomerName, o.Amount, o.Type
        FROM orders o
        INNER JOIN customer c ON o.CustomerID = c.CustomerID
        """)
        orders = cursor.fetchall()
        for order in orders:
            print(f"OrderID: {order[0]}\nCustomer Name: {order[1]}\nAmount: {order[2]}\nType: {order[3]}\n")
    except mysql.connector.Error as err:
        print(f"Error: {err}")
    finally:
        if conn.is_connected():
            conn.close()





def order_items(user_id):
    conn = create_connection()
    cursor = conn.cursor()
    item_name= input("enter itemname:")
    quantity = int(input("enter quantity:"))
    try:
        cursor.execute("""
            INSERT INTO orders (CustomerID, ItemName, Quantity)
            VALUES (%s, %s, %s)
            """, (user_id, item_name, quantity))
        conn.commit()
        print("Order placed successfully.")
    except mysql.connector.Error as err:
        print(f"Error: {err}")
    finally:
        if conn.is_connected():
            conn.close()


def check_discounts():
    conn = create_connection()
    cursor = conn.cursor()
    try:
        discount_code = input("Enter discount code: ")
        cursor.execute("""
        SELECT *
        FROM discount
        WHERE DiscountCode = %s AND ValidFrom <= CURDATE() AND ValidTo >= CURDATE()
        """, (discount_code,))
        discount = cursor.fetchone()
        if discount:
            print("Discount code is valid!")
            print(f"Percentage: {discount[2]}")
        else:
            print("Invalid discount code or expired.")
    except mysql.connector.Error as err:
        print(f"Error: {err}")
    finally:
        if conn.is_connected():
            conn.close()

def give_feedback():
    print("Give feedback!")
    conn = create_connection()
    cursor = conn.cursor()
    try:
        # Prompt user for input
        order_id = input("Enter OrderID: ")
        rating = input("Enter Rating (1-5): ")
        review = input("Enter Review: ")

        # Insert feedback into the database
        cursor.execute("""
        INSERT INTO feedback (OrderID, Rating, Review)
        VALUES (%s, %s, %s)
        """, (order_id, rating, review))
        conn.commit()

        print("Feedback submitted successfully!")
    except mysql.connector.Error as err:
        print(f"Error: {err}")
    finally:
        if conn.is_connected():
            conn.close()

def main_menu(user_id):
    while True:
        print("1. View Services\n2. View past orders\n4. Check coupon codes\n5. Order items\n6. EXIT")
        choice = input("Enter your choice: ")
        if choice == '1':
            view_services(user_id)  # Pass the user_id to the view_catalogue function
        elif choice == '2':
            view_orders()  # The user_id is already being passed here
        elif choice == '4':
            check_discounts()
        elif choice == '5':
            order_items()
        elif choice == '6':
            give_feedback()

        else:
            print("Invalid choice.")


def main():
    user_id = None
    while not user_id:
        print("1. Login\n2. Register\n3. Exit")
        choice = input("Enter your choice: ")
        if choice == '1':
            user_id = login_user(0)
            if user_id:
                main_menu(user_id)
        elif choice == '2':
            if register_user():
                print("Now, please log in.")
        elif choice == '3':
            break
        else:
            print("Invalid choice.")


if __name__ == "__main__":
    main()




# Non conflicting transactions

# Transaction 1: Place Order and Make Payment
def place_order_and_make_payment(customer_id, service_type, amount):
    try:
        conn = create_connection()
        cursor = conn.cursor()

        cursor.execute("INSERT INTO orders (Amount, Type, CustomerID) VALUES (%s, %s, %s)",
                       (amount, service_type, customer_id))
        
        cursor.execute("INSERT INTO payments (Amount, Date, CustomerID) VALUES (%s, CURDATE(), %s)",
                       (amount, customer_id))

        conn.commit()
        print("Order placed and payment made successfully.")

    except mysql.connector.Error as err:
        print(f"Error: {err}")
        conn.rollback()

    finally:
        if conn.is_connected():
            conn.close()

# Transaction 2: View Available Services and Discounts
def view_services_and_discounts():
    try:
        conn = create_connection()
        cursor = conn.cursor()

        cursor.execute("SELECT * FROM profile")
        services = cursor.fetchall()

        cursor.execute("SELECT * FROM discount WHERE ValidFrom <= CURDATE() AND ValidTo >= CURDATE()")
        discounts = cursor.fetchall()

        conn.commit()
        print("Available Services:")
        for service in services:
            print(service)
        print("\nActive Discounts:")
        for discount in discounts:
            print(discount)

    except mysql.connector.Error as err:
        print(f"Error: {err}")
        conn.rollback()

    finally:
        if conn.is_connected():
            conn.close()

# Transaction 3: Add Feedback for Completed Order
def add_feedback(order_id, rating, review):
    try:
        conn = create_connection()
        cursor = conn.cursor()

        cursor.execute("INSERT INTO feedback (OrderID, Rating, Review) VALUES (%s, %s, %s)",
                       (order_id, rating, review))

        conn.commit()
        print("Feedback added successfully.")

    except mysql.connector.Error as err:
        print(f"Error: {err}")
        conn.rollback()

    finally:
        if conn.is_connected():
            conn.close()

# Transaction 4: Send Notification for Low Inventory
def send_notification_for_low_inventory(service_type):
    try:
        conn = create_connection()
        cursor = conn.cursor()

        cursor.execute("SELECT COUNT(*) FROM orders WHERE Type = %s", (service_type,))
        order_count = cursor.fetchone()[0]

        if order_count <= 5:
            cursor.execute("INSERT INTO notification (UserID, Message, SentDateTime) VALUES (%s, %s, NOW())",
                           (1, f"Low inventory for service: {service_type}"))

        conn.commit()
        print("Notification sent for low inventory.")

    except mysql.connector.Error as err:
        print(f"Error: {err}")
        conn.rollback()

    finally:
        if conn.is_connected():
            conn.close()

# Execute the transactions
def execute_transactions():
    # Transaction 1: Place Order and Make Payment
    place_order_and_make_payment(1, 'Dry Cleaning', 25.00)

    # Transaction 2: View Available Services and Discounts
    view_services_and_discounts()

    # Transaction 3: Add Feedback for Completed Order
    add_feedback(1, 4, "Great service, my clothes look amazing!")

    # Transaction 4: Send Notification for Low Inventory
    send_notification_for_low_inventory('Wash & Fold')



# Conflicting transactions

# Transaction 1: Place Order and Deduct Inventory
def place_order_and_deduct_inventory(customer_id, service_type, amount):
    try:
        conn = create_connection()
        cursor = conn.cursor()

        cursor.execute("INSERT INTO orders (Amount, Type, CustomerID) VALUES (%s, %s, %s)",
                       (amount, service_type, customer_id))

        cursor.execute("UPDATE services SET InventoryCount = InventoryCount - 1 WHERE Type = %s",
                       (service_type,))

        conn.commit()
        print("Order placed and inventory deducted successfully.")

    except mysql.connector.Error as err:
        print(f"Error: {err}")
        conn.rollback()

    finally:
        if conn.is_connected():
            conn.close()

# Transaction 2: View Available Services and Inventory
def view_services_and_inventory():
    try:
        conn = create_connection()
        cursor = conn.cursor()

        cursor.execute("SELECT * FROM profile")
        services = cursor.fetchall()

        cursor.execute("SELECT Type, InventoryCount FROM services")
        inventory = cursor.fetchall()
        conn.commit()

        print("Available Services:")
        for service in services:
            print(service)
        print("\nInventory Count:")
        for item in inventory:
            print(item)

    except mysql.connector.Error as err:
        print(f"Error: {err}")
        conn.rollback()

    finally:
        if conn.is_connected():
            conn.close()

def execute_conflicting_transactions():
    # Transaction 1: Place Order and Deduct Inventory
    place_order_and_deduct_inventory(1, 'Dry Cleaning', 25.00)

    # Transaction 2: View Available Services and Inventory
    view_services_and_inventory()

# Execute all transactions
execute_transactions()

# Execute conflicting transactions
execute_conflicting_transactions()