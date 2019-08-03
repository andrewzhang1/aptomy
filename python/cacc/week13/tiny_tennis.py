###
# tiny tennis game
###

def reset_ball():
    return screen_width // 2, screen_height//2


# * imports, setup game area and static parts
# ** import
import pygame
import time

# ** initialize the game
pygame.init()

# ** define global variable
# *** color
red = (255, 0, 0)
orange = (255, 127, 0)
yellow = (255, 255, 0)
green = (0, 255, 0)
blue = (0, 0, 255)
violet = (127, 0, 255)
brown = (102, 51, 0)
black = (0, 0, 0)
white = (255, 255, 255)

# *** game surface
game_surface_resolution = screen_width, screen_height = 600, 500

# *** ball
# position
ball_x = int(screen_width / 2)
ball_y = screen_height // 2
# speed
ball_xv = 3
ball_yv = 3
# size
ball_r = 20

# *** paddle
paddle1_x, paddle1_y, paddle1_w, paddle1_h = 10, 10, 25, 100
paddle2_x, paddle2_y, paddle2_w, paddle2_h = screen_width - 35, 10, 25, 100

# *** score
player1_score = 0
player2_score = 0

# ** draw surface
# *** surface
game_surface = pygame.display.set_mode(game_surface_resolution)
pygame.display.set_caption("Tiny Tennis")
font = pygame.font.SysFont("monospace", 75)

pygame.mouse.set_visible(False)
run_main_loop = True
while run_main_loop:
    pressed = pygame.key.get_pressed()
    pygame.key.set_repeat()
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            run_main_loop = False
    if pressed[pygame.K_ESCAPE]:
        run_main_loop = False

    # move the paddles
    if pressed[pygame.K_w]:
        paddle1_y -= 5
    elif pressed[pygame.K_s]:
        paddle1_y += 5

    if pressed[pygame.K_UP]:
        paddle2_y -= 5
    elif pressed[pygame.K_DOWN]:
        paddle2_y += 5

    # paddle collision detection of edge
    if paddle1_y < 0: paddle1_y = 0
    if paddle1_y + paddle1_h > screen_height: paddle1_y = screen_height - paddle1_h

    if paddle2_y < 0: paddle2_y = 0
    if paddle2_y + paddle2_h > screen_height: paddle2_y = screen_height - paddle2_h

    game_surface.fill(black)
    pygame.draw.rect(game_surface, white, (paddle1_x, paddle1_y, paddle1_w, paddle1_h))
    pygame.draw.rect(game_surface, white, (paddle2_x, paddle2_y, paddle2_w, paddle2_h))

    # move the ball
    ball_x += ball_xv
    ball_y += ball_yv

    # ball collision detection of top/bottom
    if ball_y - ball_r <=0 or ball_y + ball_r >= screen_height:
        ball_yv *= -1

    # ball with paddle collision detection
    # left paddle
    if ball_x < paddle1_x + paddle1_w and ball_y > paddle1_y and ball_y <= paddle1_y + paddle1_h:
        ball_xv *= -1
    if ball_x > paddle2_x and paddle2_y + paddle2_h >= ball_y >= paddle2_y:
        ball_xv *= -1
    ball = pygame.draw.circle(game_surface, red, (ball_x, ball_y), ball_r)

    # keep score
    if ball_x <= 0:
        player2_score += 1
        ball_x, ball_y = reset_ball()
    elif ball_x >= screen_width:
        player1_score += 1
        ball_x, ball_y = reset_ball()
    score_text = font.render(str(player1_score) + " " + str(player2_score), 1, white)
    game_surface.blit(score_text, (screen_width / 2 - score_text.get_width() / 2, 10))
    net = pygame.draw.line(game_surface, yellow, (screen_width//2, 5), (screen_width//2, screen_height - 5))
    # net = pygame.draw.line(game_surface, yellow, (300, 5), (300, 400))
    pygame.display.update()
    time.sleep(0.02)

pygame.quit()

